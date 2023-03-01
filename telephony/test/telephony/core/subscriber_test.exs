defmodule Telephony.Core.SubscriberTest do
  @moduledoc false
  use ExUnit.Case
  alias Telephony.Core.{Call, Prepaid, Pospaid, Subscriber}

  setup do
    pospaid = %Subscriber{
      full_name: "Jhon",
      phone_number: "123",
      type: %Pospaid{spent: 0}
    }

    prepaid = %Subscriber{
      full_name: "Jhon",
      phone_number: "123",
      type: %Prepaid{credits: 10, recharges: []}
    }

    %{pospaid: pospaid, prepaid: prepaid}
  end

  test "create prepaid subscriber" do
    payload = %{
      full_name: "Jhon",
      phone_number: "123",
      type: :prepaid
    }

    result = Subscriber.new(payload)

    expect = %Subscriber{
      full_name: "Jhon",
      phone_number: "123",
      type: %Prepaid{credits: 0, recharges: []}
    }

    assert expect == result
  end

  test "create postpaid subscriber" do
    payload = %{
      full_name: "Jhon",
      phone_number: "123",
      type: :pospaid
    }

    result = Subscriber.new(payload)

    expect = %Subscriber{
      full_name: "Jhon",
      phone_number: "123",
      type: %Pospaid{spent: 0}
    }

    assert expect == result
  end

  test "make prepaid call" do
    subscriber = %Subscriber{
      full_name: "Jhon",
      phone_number: "123",
      type: %Prepaid{credits: 10, recharges: []}
    }

    date = DateTime.utc_now()

    expect = %Subscriber{
      calls: %Call{date: date, time_spent: 1},
      full_name: "Jhon",
      phone_number: "123",
      type: %Prepaid{credits: 8.55, recharges: []}
    }

    assert Subscriber.make_call(subscriber, 1, date) == expect
  end

  test "make pospaid call" do
    subscriber = %Subscriber{
      full_name: "Jhon",
      phone_number: "123",
      type: %Pospaid{spent: 0}
    }

    date = DateTime.utc_now()

    expect = %Subscriber{
      calls: %Call{date: date, time_spent: 1},
      full_name: "Jhon",
      phone_number: "123",
      type: %Pospaid{spent: 1.04}
    }

    assert Subscriber.make_call(subscriber, 1, date) == expect
  end

  test "make prepaid call without credits" do
    subscriber = %Subscriber{
      full_name: "Jhon",
      phone_number: "123",
      type: %Prepaid{credits: 0, recharges: []}
    }

    date = DateTime.utc_now()

    expect = {:error, "subscriber does not have credits"}

    assert Subscriber.make_call(subscriber, 1, date) == expect
  end

  test "make recharge" do
    subscriber = %Subscriber{
      full_name: "Jhon",
      phone_number: "123",
      type: %Pospaid{spent: 1.04}
    }

    date = DateTime.utc_now()

    expect = {:error, "Only a prepaid can make a recharge"}

    assert Subscriber.make_recharge(subscriber, 10, date) == expect
  end
end
