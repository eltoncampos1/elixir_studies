defmodule Telephony.Core.PrepaidTest do
  @moduledoc false
  use ExUnit.Case
  alias Telephony.Core.{Call, Prepaid, Recharge}

  setup do
    sub = %Telephony.Core.Subscriber{
      full_name: "Jhon",
      phone_number: "123",
      subscriber_type: %Prepaid{credits: 10, recharges: []}
    }

    sub_without_credits = %Telephony.Core.Subscriber{
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
      result = Prepaid.make_call(sub, time_spent, date)

      expect = %Telephony.Core.Subscriber{
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
      result = Prepaid.make_call(sub, time_spent, date)

      expect = {:error, "subscriber does not have credits"}

      assert expect == result
    end

    test "make a recharge", %{subscriber: sub} do
      value = 100
      date = NaiveDateTime.utc_now()
      result = Prepaid.make_recharge(sub, value, date)

      expect = %Telephony.Core.Subscriber{
        full_name: "Jhon",
        phone_number: "123",
        subscriber_type: %Prepaid{credits: 110, recharges: [%Recharge{value: value, date: date}]},
        calls: []
      }

      assert expect == result
    end

    test "print invoice", %{subscriber: sub} do
      value = 100
      date = ~D[2023-02-16]
      last_month = ~D[2023-01-16]

      subscriber = %Telephony.Core.Subscriber{
        full_name: "Jhon",
        phone_number: "123",
        subscriber_type: %Prepaid{
          credits: 110,
          recharges: [
            %Recharge{value: value, date: date},
            %Recharge{value: value, date: last_month},
            %Recharge{value: value, date: last_month}
          ]
        },
        calls: [
          %Call{
            time_spent: 2,
            date: last_month
          },
          %Call{
            time_spent: 10,
            date: date
          },
          %Call{
            time_spent: 20,
            date: date
          }
        ]
      }

      %{subscriber_type: subscriber_type, calls: calls} = subscriber

      assert Subscriber.print_invoice(subscriber_type, calls, 02, 2023) == %{
               calls: [
                 %{
                   time_spent: 10,
                   value_spent: 14.5,
                   date: date
                 },
                 %{
                   time_spent: 20,
                   value_spent: 29.0,
                   date: date
                 }
               ],
               recharges: [
                 %Recharge{value: value, date: date}
               ],
               credits: 110
             }
    end
  end
end
