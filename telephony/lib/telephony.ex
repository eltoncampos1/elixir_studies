defmodule Telephony do
  def start do
    File.write("plans/pre.txt", :erlang.term_to_binary([]))
    File.write("plans/post.txt", :erlang.term_to_binary([]))
  end

  def register_subscriber(name, number, cpf, plan) do
    Subscriber.register(name, number, cpf, plan)
  end

  def list_subscribers, do: Subscriber.subscribers
  def list_prepaid_subscribers, do: Subscriber.prepaid_subscribers
  def list_postpaid_subscribers, do: Subscriber.postpaid_subscribers



  def make_call(number, plan, date, duration) do
    cond do
      plan == :prepaid -> Prepaid.make_call(number, date, duration)
      plan == :postpaid -> Postpaid.make_call(number, date, duration)
    end
  end

  def recharge(number, date, value), do: Recharge.new(date, value, number)

  def find_by_number(number, plan \\ :all), do: Subscriber.find_subscriber(number, plan)

  def print_bills(month, year) do
    Subscriber.prepaid_subscribers
    |> Enum.each(fn sub ->
      sub = Prepaid.pint_bill(month, year, sub.number)
      IO.puts "Prepaid account from subscriber: #{sub.name}"
      IO.puts "Number: #{sub.number}"
      IO.puts "Calls: "
      IO.inspect sub.calls
      IO.puts "Recharges"
      IO.inspect sub.plan.recharges
      IO.puts "Total calls: #{Enum.count(sub.calls)}"
      IO.puts "Total recharges: #{Enum.count(sub.plan.recharges)}"
      IO.puts "===================================================="
    end)

    Subscriber.postpaid_subscribers
    |> Enum.each(fn sub ->
      sub = Postpaid.print_bill(month, year, sub.number)
      IO.puts "Postpaid account from subscriber: #{sub.name}"
      IO.puts "Number: #{sub.number}"
      IO.puts "Calls: "
      IO.inspect sub.calls
      IO.puts "Total calls: #{Enum.count(sub.calls)}"
      IO.puts "Total invoice: #{sub.plan.value}"
      IO.puts "===================================================="
    end)
  end
end
