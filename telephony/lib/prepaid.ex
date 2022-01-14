defmodule Prepaid do
  @moduledoc """
  Prepaid bussines rules
  """

  defstruct credits: 0, recharges: []

  @price_per_minute 1.45

  def make_call(number, date, duration) do
    subscriber = Subscriber.find_subscriber(number, :prepaid)
    cost = @price_per_minute * duration
    cond do
      cost <= subscriber.plan.credits ->
      plan = subscriber.plan
      plan = %__MODULE__{plan | credits: plan.credits - cost}
      %Subscriber{subscriber | plan: plan}

      |> Call.register(date, duration)
        {:ok, "Will be charged the value of #{cost} for the call, you still have #{plan.credits} credits"}
        true ->
          {:error, "You don't have enough credits to make the call, please top up"}
    end
  end
end
