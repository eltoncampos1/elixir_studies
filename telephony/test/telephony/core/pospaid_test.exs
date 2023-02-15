defmodule Telephony.Core.PospaidTest do
  @moduledoc false
  use ExUnit.Case
  alias Telephony.Core.Pospaid
  alias Telephony.Core.{Call, Subscriber}

  setup  do
    sub = %Subscriber{
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
      result  = Pospaid.make_call(sub, time_spent, date)

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

  end
end
