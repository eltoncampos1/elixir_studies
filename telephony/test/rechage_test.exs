defmodule RechargeTest do
  use ExUnit.Case
  setup do
    File.write("plans/pre.txt", :erlang.term_to_binary([]))
    File.write("plans/post.txt", :erlang.term_to_binary([]))

    on_exit(fn ->
      File.rm("plans/pre.txt")
      File.rm("plans/post.txt")
    end)
  end


  test "Should make an recharge" do
    sub = Subscriber.register("user123", "123", "123", :prepaid)

    {:ok, msg} = Recharge.new(DateTime.utc_now(), 30, "123")
    assert msg = "Recharge performed successfully"
    sub = Subscriber.find_subscriber("123", :prepaid)
    assert sub.plan.credits == 30
    assert Enum.count(sub.plan.recharges) == 1
  end
end
