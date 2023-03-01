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


end
