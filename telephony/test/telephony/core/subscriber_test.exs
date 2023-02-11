defmodule Telephony.Core.SubscriberTest do
  @moduledoc false
  use ExUnit.Case
  alias Telephony.Core.Subscriber

  test "create subscriber" do
    payload = %{
      full_name: "Jhon",
      phone_number: "123"
    }

    result = Subscriber.new(payload)

    expect = %Subscriber{
      full_name: "Jhon",
      phone_number: "123",
      subscriber_type: :prepaid
    }

    assert expect == result
  end
end
