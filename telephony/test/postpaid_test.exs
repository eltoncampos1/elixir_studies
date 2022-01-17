defmodule PostpaidTest do
  use ExUnit.Case

  setup do
    File.write("plans/pre.txt", :erlang.term_to_binary([]))
    File.write("plans/post.txt", :erlang.term_to_binary([]))

    on_exit(fn ->
      File.rm("plans/pre.txt")
      File.rm("plans/post.txt")
    end)
  end

  test "Should make a call" do
    Subscriber.register("user123", "123", "123", :postpaid)

    assert Postpaid.make_call("123", DateTime.utc_now(), 5) == {:ok, "call successfully done! with duration: 5 minutes"}
  end

  test "should notify the bill values of month" do
    Subscriber.register("user123", "123", "123", :postpaid)
     date = DateTime.utc_now()
     old_date = ~U[2021-12-17 15:15:33.253833Z]
     Postpaid.make_call("123", date, 3)
     Postpaid.make_call("123", date, 3)
     Postpaid.make_call("123", date, 3)

     Postpaid.make_call("123", old_date, 3)

     sub = Subscriber.find_subscriber("123", :postpaid)
     assert Enum.count(sub.calls) == 4

     sub = Postpaid.print_bill(date.month, date.year, "123")

     assert sub.number == "123"
     assert Enum.count(sub.calls) == 3
     assert sub.plan.value ==  12.599999999999998
   end
end
