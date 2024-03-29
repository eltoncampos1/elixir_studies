defmodule Telephony.ServerTest do
  @moduledoc false

  use ExUnit.Case
  alias Telephony.Server

  alias Telephony.Core.{Prepaid, Subscriber}

  setup do
    {:ok, pid} = Server.start_link(:test)

    payload = %{
      full_name: "User test",
      phone_number: "123456",
      type: :prepaid
    }

    %{pid: pid, process_name: :test, payload: payload}
  end

  test "check telephony subscribers state", %{pid: pid} do
    assert [] == :sys.get_state(pid)
  end

  test "create a subscriber", %{pid: pid, process_name: process_name, payload: payload} do
    old_state = :sys.get_state(pid)
    assert [] == old_state
    result = GenServer.call(process_name, {:create_subscriber, payload})

    assert [
             %Subscriber{
               calls: [],
               full_name: "User test",
               phone_number: "123456",
               type: %Prepaid{credits: 0, recharges: []}
             }
           ] ==
             result

    refute old_state == result
  end

  test "error message when try to create a subscriber", %{
    pid: pid,
    process_name: process_name,
    payload: payload
  } do
    old_state = :sys.get_state(pid)
    assert [] == old_state
    GenServer.call(process_name, {:create_subscriber, payload})
    result = GenServer.call(process_name, {:create_subscriber, payload})
    assert {:error, "Subscriber `123456`, already exists"} == result
  end

  test "search subscriber", %{process_name: process_name, payload: payload} do
    GenServer.call(process_name, {:create_subscriber, payload})
    result = GenServer.call(process_name, {:search_subscriber, payload.phone_number})
    assert result.phone_number == payload.phone_number
  end

  test "make a recharge", %{pid: pid, process_name: process_name, payload: payload} do
    GenServer.call(process_name, {:create_subscriber, payload})
    date = Date.utc_today()
    state = :sys.get_state(pid)
    sub_state = hd(state)
    assert sub_state.type.recharges == []
    :ok = GenServer.cast(process_name, {:make_recharge, payload.phone_number, 10, date})
    state = :sys.get_state(pid)
    sub_state = hd(state)
    refute sub_state.type.recharges == []
  end

  test "make a call", %{pid: pid, process_name: process_name, payload: payload} do
    date = Date.utc_today()
    GenServer.call(process_name, {:create_subscriber, payload})
    state = :sys.get_state(pid)
    sub_state = hd(state)
    assert sub_state.calls == []
    :ok = GenServer.cast(process_name, {:make_recharge, payload.phone_number, 100, date})
    result = GenServer.call(process_name, {:make_call, payload.phone_number, 10, date})
    refute result.calls == []
  end

  test "make an error call", %{process_name: process_name, payload: payload} do
    date = Date.utc_today()
    GenServer.call(process_name, {:create_subscriber, payload})
    result = GenServer.call(process_name, {:make_call, payload.phone_number, 10, date})
    assert result == {:error, "subscriber does not have credits"}
  end

  test "print invoice", %{process_name: process_name, payload: payload} do
    date = Date.utc_today()
    GenServer.call(process_name, {:create_subscriber, payload})
    :ok = GenServer.cast(process_name, {:make_recharge, payload.phone_number, 100, date})
    GenServer.call(process_name, {:make_call, payload.phone_number, 10, date})

    result =
      GenServer.call(process_name, {:print_invoice, payload.phone_number, date.month, date.year})

    assert result.invoice.calls == [%{date: date, time_spent: 10, value_spent: 14.5}]
  end
end
