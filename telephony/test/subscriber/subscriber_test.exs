defmodule Subscriber.SubscriberTest do
  @moduledoc """

  """
  use ExUnit.Case
  alias Subscriber.Subscriber

  test "create subscriber" do
    payload = %{
      full_name: "Jhon",
      id: "123",
      phone_number: "123"
    }

    result = Subscriber.new(payload)

    expect  = %Subscriber{
      full_name: "Jhon",
      id: "123",
      phone_number: "123",
      subscriber_type: :prepaid
    }

    assert expect == result
  end
end
