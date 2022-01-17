defmodule Postpaid do
  @moduledoc """
  Postpaid bussines rules
  """

  defstruct value: 0

  @cost_per_minute 1.40

  def make_call(number, date, duration) do
    Subscriber.find_subscriber(number, :postpaid)
    |> Call.register(date, duration)
    {:ok, "call successfully done! with duration: #{duration} minutes"}
  end

  def print_bill(month, year, number) do
    sub = Bill.print(month, year, number, :postpaid)

    total_value = sub.calls
    |> Enum.map(&(&1.duration * @cost_per_minute))
    |> Enum.sum()

    %Subscriber{sub | plan: %__MODULE__{value: total_value}}
  end
end
