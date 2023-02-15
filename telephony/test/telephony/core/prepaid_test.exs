defmodule Telephony.Core.PrepaidTest do
  @moduledoc false
  use ExUnit.Case
  alias Telephony.Core.{Call, Prepaid, Recharge, Subscriber}

  setup  do
    sub = %Subscriber{
      full_name: "Jhon",
      phone_number: "123",
      subscriber_type: %Prepaid{credits: 10, recharges: []}
    }

    sub_without_credits = %Subscriber{
      full_name: "Jhon Doe",
      phone_number: "12356",
      subscriber_type: %Prepaid{credits: 0, recharges: []}
    }

    %{subscriber: sub, subscriber_without_credits: sub_without_credits}
  end

  describe "prepaid" do
    test "make a call", %{subscriber: sub} do
      time_spent = 2
      date = NaiveDateTime.utc_now()
      result  = Prepaid.make_call(sub, time_spent, date)

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

    test "try to make a call", %{subscriber_without_credits: sub} do

      time_spent = 2
      date = NaiveDateTime.utc_now()
      result  = Prepaid.make_call(sub, time_spent, date)

      expect =  {:error, "subscriber does not have credits"}

      assert expect == result
    end

    test "make a recharge", %{subscriber: sub} do
      value = 100
      date = NaiveDateTime.utc_now()
      result = Prepaid.make_recharge(sub, value, date)

      expect = %Subscriber{
        full_name: "Jhon",
        phone_number: "123",
        subscriber_type: %Prepaid{credits: 110, recharges: [%Recharge{value: value, date: date}]},
        calls: []
      }

     assert expect == result
    end
  end
end
