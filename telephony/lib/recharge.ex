defmodule Recharge do
  defstruct date: nil, value: nil

  def new(date, value, number) do
    sub = Subscriber.find_subscriber(number, :prepaid)
    plan = sub.plan

    plan = %Prepaid{
      plan
      | credits: plan.credits + value,
        recharges: plan.recharges ++ [%__MODULE__{date: date, value: value}]
    }

    sub = %Subscriber{sub | plan: plan}
    Subscriber.update(number, sub)
    {:ok, "Recharge performed successfully"}
  end
end
