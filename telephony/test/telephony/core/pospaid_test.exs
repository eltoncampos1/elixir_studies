defmodule Telephony.Core.PospaidTest do
  @moduledoc false
  use ExUnit.Case
  alias Telephony.Core.Pospaid
  alias Telephony.Core.Call

  setup do
    %{pospaid: %Pospaid{spent: 0}}
  end

  describe "pospaid" do
    test "make a call", %{pospaid: sub} do
      time_spent = 2
      date = NaiveDateTime.utc_now()
      result = Subscriber.make_call(sub, time_spent, date)

      expect = {%Pospaid{spent: 2.08}, %Call{date: date, time_spent: 2}}

      assert expect == result
    end

    test "print invoice" do
      date = ~D[2023-02-16]
      last_month = ~D[2023-01-16]

      pospaid = %Pospaid{spent: 90 * 1.04}

      calls = [
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

      assert expect === Subscriber.print_invoice(pospaid, calls, 01, 2023)
    end

    test "make a rechage" do
      pospaid = %Pospaid{spent: 90 * 1.04}
      date = NaiveDateTime.utc_now()

      assert {:error, "Only a prepaid can make a recharge"} ==
               Subscriber.make_recharge(pospaid, 10, date)
    end
  end
end
