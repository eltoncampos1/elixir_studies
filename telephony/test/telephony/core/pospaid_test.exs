defmodule Telephony.Core.PospaidTest do
  @moduledoc false
  use ExUnit.Case
  alias Telephony.Core.Pospaid
  alias Telephony.Core.Call

  setup do
    sub = %Telephony.Core.Subscriber{
      full_name: "Jhon",
      phone_number: "123",
      subscriber_type: %Pospaid{spent: 0},
      calls: []
    }

    %{subscriber: sub}
  end

  describe "pospaid" do
    test "make a call", %{subscriber: sub} do
      time_spent = 2
      date = NaiveDateTime.utc_now()
      result = Pospaid.make_call(sub, time_spent, date)

      expect = %Telephony.Core.Subscriber{
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

    test "print invoice", %{subscriber: sub} do
      date = ~D[2023-02-16]
      last_month = ~D[2023-01-16]

      subscriber = %Telephony.Core.Subscriber{
        full_name: "Jhon",
        phone_number: "123",
        subscriber_type: %Pospaid{spent: 90 * 1.04},
        calls: [
          %Call{
            time_spent: 10,
            date: date
          },
          %Call{
            time_spent: 50,
            date: last_month
          },
          %Call{
            time_spent: 30,
            date: last_month
          }
        ]
      }

      %{subscriber_type: subscriber_type, calls: calls} = subscriber

      expect = %{
        value_spent: 80 * 1.04,
        calls: [
          %{
            time_spent: 50,
            value_spent: 50 * 1.04,
            date: last_month
          },
          %{
            time_spent: 30,
            value_spent: 30 * 1.04,
            date: last_month
          }
        ]
      }

      assert expect === Subscriber.print_invoice(subscriber_type, calls, 01, 2023)
    end
  end
end
