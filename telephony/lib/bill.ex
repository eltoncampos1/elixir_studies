defmodule Bill do
  def print(month, year, number, plan) do
    sub = Subscriber.find_subscriber(number)
    month_calls = find_elements_by_month(sub.calls, month, year)

    cond do
      plan == :prepaid ->
        month_recharges = find_elements_by_month(sub.plan.recharges, month, year)
        plan = %Prepaid{sub.plan | recharges: month_recharges}
        %Subscriber{sub | calls: month_calls, plan: plan}
      plan == :postpaid ->
        %Subscriber{sub | calls: month_calls}
    end
  end

  def find_elements_by_month(elements, month, year) do
    elements
    |> Enum.filter(&(&1.date.year == year && &1.date.month == month))
  end
end
