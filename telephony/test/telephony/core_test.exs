defmodule Telephony.CoreTest do
  @moduledoc false
  use ExUnit.Case
  alias Telephony.Core
  alias Telephony.Core.{Prepaid, Pospaid, Subscriber}

  setup do
    subscribers = [
      %Subscriber{
        full_name: "Jhon",
        phone_number: "123",
        type: %Prepaid{credits: 0, recharges: []}
      },
      %Subscriber{
        full_name: "Jhon",
        phone_number: "12345",
        type: %Pospaid{spent: 2.08}
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
      },
      %Subscriber{
        calls: [],
        full_name: "Jhon",
        phone_number: "12345",
        type: %Telephony.Core.Pospaid{spent: 2.08}
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

  test "search a subscriber", %{subscribers: subscribers} do
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

  test "make prepaid recharge", %{subscribers: subscribers} do
    date = Date.utc_today()

    expect = {
      [
        %Telephony.Core.Subscriber{
          calls: [],
          full_name: "Jhon",
          phone_number: "12345",
          type: %Telephony.Core.Pospaid{spent: 2.08}
        },
        %Telephony.Core.Subscriber{
          calls: [],
          full_name: "Jhon",
          phone_number: "123",
          type: %Telephony.Core.Prepaid{
            credits: 1,
            recharges: [%Telephony.Core.Recharge{date: date, value: 1}]
          }
        }
      ],
      %Telephony.Core.Subscriber{
        calls: [],
        full_name: "Jhon",
        phone_number: "123",
        type: %Telephony.Core.Prepaid{
          credits: 1,
          recharges: [
            %Telephony.Core.Recharge{
              date: date,
              value: 1
            }
          ]
        }
      }
    }

    result = Core.make_recharge(subscribers, "123", 1, date)
    assert expect == result
  end

  test "make pospaid recharge", %{subscribers: subscribers} do
    date = Date.utc_today()

    expect = {
      [
        %Subscriber{
          calls: [],
          full_name: "Jhon",
          phone_number: "123",
          type: %Prepaid{credits: 0, recharges: []}
        }
      ],
      {:error, "Only a prepaid can make a recharge"}
    }

    result = Core.make_recharge(subscribers, "12345", 1, date)
    assert expect == result
  end

  test "make a call", %{subscribers: subscribers} do
    date = Date.utc_today()

    expect =
      {[
         %Subscriber{
           calls: [],
           full_name: "Jhon",
           phone_number: "12345",
           type: %Pospaid{spent: 2.08}
         }
       ], {:error, "subscriber does not have credits"}}

    result = Core.make_call(subscribers, "123", 1, date)

    assert result == expect
  end

  test "print invoice", %{subscribers: subscribers} do
    date = Date.utc_today()

    expect = %{
      invoice: %{calls: [], credits: 0, recharges: []},
      subscriber: %Subscriber{
        calls: [],
        full_name: "Jhon",
        phone_number: "123",
        type: %Prepaid{credits: 0, recharges: []}
      }
    }

    result = Core.print_invoice(subscribers, "123", date.month, date.year)

    assert result == expect
  end

  test "print all invoices", %{subscribers: subscribers} do
    date = Date.utc_today()
    result = Core.print_invoices(subscribers, date.month, date.year)

    expect = [
      %{
        invoice: %{calls: [], credits: 0, recharges: []},
        subscriber: %Subscriber{
          calls: [],
          full_name: "Jhon",
          phone_number: "123",
          type: %Prepaid{credits: 0, recharges: []}
        }
      },
      %{
        invoice: %{calls: [], value_spent: 0},
        subscriber: %Subscriber{
          calls: [],
          full_name: "Jhon",
          phone_number: "12345",
          type: %Pospaid{spent: 2.08}
        }
      }
    ]

    assert result == expect
  end
end
