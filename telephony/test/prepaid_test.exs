defmodule PrepaidTest do
  use ExUnit.Case
  doctest Prepaid

  setup do
    File.write("plans/pre.txt", :erlang.term_to_binary([]))
    File.write("plans/post.txt", :erlang.term_to_binary([]))

    on_exit(fn ->
      File.rm("plans/pre.txt")
      File.rm("plans/post.txt")
    end)
  end

  describe "Call functions" do
    test "Should make a call" do
      Subscriber.register("user123", "123", "123", :prepaid)
      Recharge.new(DateTime.utc_now(), 10, "123")

      assert Prepaid.make_call("123", DateTime.utc_now(), 3) ==
               {:ok,
                "Will be charged the value of 4.35 for the call, you still have 5.65 credits"}
    end

    test "Should return an erro if make a long call with no credits" do
      Subscriber.register("user123", "123", "123", :prepaid)
      Recharge.new(DateTime.utc_now(), 10, "123")

      assert Prepaid.make_call("123", DateTime.utc_now(), 10) ==
               {:error, "You don't have enough credits to make the call, please top up"}
    end
  end

  describe "Test to bill printing" do
    test "should notify the bill values of month" do
     Subscriber.register("user123", "123", "123", :prepaid)
      date = DateTime.utc_now()
      old_date = ~U[2021-12-17 15:15:33.253833Z]
      Recharge.new(date, 10, "123")
      Prepaid.make_call("123", date, 3)
      Recharge.new(old_date, 10, "123")
      Prepaid.make_call("123", old_date, 3)

      sub = Subscriber.find_subscriber("123", :prepaid)
      assert Enum.count(sub.calls) == 2
      assert Enum.count(sub.plan.recharges) == 2

      sub = Prepaid.pint_bill(date.month, date.year, "123")

      assert sub.number == "123"
      assert Enum.count(sub.calls) == 1
      assert Enum.count(sub.plan.recharges) == 1
    end
  end
end
