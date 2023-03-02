defmodule Telephony.CoreTest do
  @moduledoc false
  use ExUnit.Case
  alias Telephony.Core
  alias Telephony.Core.Subscriber
  alias Telephony.Core.Prepaid

  setup do
    subscribers = [
      %Subscriber{
        full_name: "Jhon",
        phone_number: "123",
        type: %Prepaid{credits: 0, recharges: []}
      }
    ]

    payload = %{
      full_name: "Jhon",
      phone_number: "123",
      type: :prepaid
    }

    %{subscribers: subscribers, payload: payload}
  end

  test "create new subscriber", %{payload: payload} do
    subscribers = []

    result = Core.create_subscriber(subscribers, payload)

    expect = [
      %Subscriber{
        full_name: "Jhon",
        phone_number: "123",
        type: %Prepaid{credits: 0, recharges: []}
      }
    ]

    assert expect == result
  end

  test "create a new subscriber", %{subscribers: subscribers} do
    payload = %{
      full_name: "mary",
      phone_number: "1234",
      type: :prepaid
    }

    expect = [
      %Subscriber{
        full_name: "mary",
        phone_number: "1234",
        type: %Prepaid{credits: 0, recharges: []}
      },
      %Subscriber{
        full_name: "Jhon",
        phone_number: "123",
        type: %Prepaid{credits: 0, recharges: []}
      }
    ]

    result = Core.create_subscriber(subscribers, payload)

    assert result == expect
  end

  test "display error, when subscriber already exists", %{
    subscribers: subscribers,
    payload: payload
  } do
    assert {:error, "Subscriber `123`, already exists"} =
             Core.create_subscriber(subscribers, payload)
  end

  test "display error, when subscriber type does not exists", %{
    subscribers: subscribers
  } do
    payload = %{
      full_name: "user",
      type: :invalid_type,
      phone_number: "8549"
    }

    assert {:error, "Only 'prepaid' or ''postpaid' are accepted"} =
             Core.create_subscriber(subscribers, payload)
  end

  test "search a subscriber",%{subscribers: subscribers} do

    expect = %Subscriber{
      full_name: "Jhon",
      phone_number: "123",
      type: %Prepaid{credits: 0, recharges: []}
    }

    result = Core.search_subscriber(subscribers, "123")
    assert expect == result
  end

  test "return nil when subscirber does not exist", %{subscribers: subscribers} do
    expect = nil

    result = Core.search_subscriber(subscribers, "321")
    assert expect == result
  end
end
