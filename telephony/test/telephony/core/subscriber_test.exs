defmodule Telephony.Core.SubscriberTest do
  @moduledoc false
  use ExUnit.Case
  alias Telephony.Core.{Call, Prepaid, Pospaid, Recharge, Subscriber}

  setup do
    pospaid = %Subscriber{
      full_name: "Jhon",
      phone_number: "123",
      subscriber_type: %Pospaid{spent: 0}
    }

    prepaid = %Subscriber{
      full_name: "Jhon",
      phone_number: "123",
      subscriber_type: %Prepaid{credits: 10, recharges: []}
    }

    %{pospaid: pospaid, prepaid: prepaid}
  end

  test "create prepaid subscriber" do
    payload = %{
      full_name: "Jhon",
      phone_number: "123",
      subscriber_type: :prepaid
    }

    result = Subscriber.new(payload)

    expect = %Subscriber{
      full_name: "Jhon",
      phone_number: "123",
      subscriber_type: %Prepaid{credits: 0, recharges: []}
    }

    assert expect == result
  end

  test "create postpaid subscriber" do
    payload = %{
      full_name: "Jhon",
      phone_number: "123",
      subscriber_type: :pospaid
    }

    result = Subscriber.new(payload)

    expect = %Subscriber{
      full_name: "Jhon",
      phone_number: "123",
      subscriber_type: %Pospaid{spent: 0}
    }

    assert expect == result
  end

  test "make a pospaid call", %{pospaid: pospaid} do
    date = NaiveDateTime.utc_now()

    result = Subscriber.make_call(pospaid, 2, date)

    expect = %Subscriber{
      full_name: "Jhon",
      phone_number: "123",
      subscriber_type: %Pospaid{spent: 2.08},
      calls: [
        %Call{
          time_spent: 2,
          date: date
        }
      ]
    }

    assert expect == result
  end

  test "make a prepaid call", %{prepaid: prepaid} do
    date = NaiveDateTime.utc_now()

    result = Subscriber.make_call(prepaid, 2, date)

    expect = %Subscriber{
      full_name: "Jhon",
      phone_number: "123",
      subscriber_type: %Prepaid{credits: 7.1, recharges: []},
      calls: [
        %Call{
          time_spent: 2,
          date: date
        }
      ]
    }

    assert expect == result
  end

  test "make a prepaid recharge", %{prepaid: prepaid} do
    date = NaiveDateTime.utc_now()
    value = 20

    result = Subscriber.make_recharge(prepaid, value, date)

    expect = %Subscriber{
      full_name: "Jhon",
      phone_number: "123",
      calls: [],
      subscriber_type: %Prepaid{credits: 30, recharges: [%Recharge{date: date, value: value}]},
    }

    assert expect == result
  end

  test "error when recharge and its not a prepaid", %{pospaid: pospaid} do
    date = NaiveDateTime.utc_now()
    value = 20

    result = Subscriber.make_recharge(pospaid, value, date)

    expect = {:error, "Only a prepaid can make a recharge"}

    assert expect == result
  end
end
