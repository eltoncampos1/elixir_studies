defmodule Telephony.Core.Pospaid do
  @moduledoc false
  defstruct spent: 0
  alias Telephony.Core.Call

  defimpl Subscriber, for: __MODULE__ do
    @price_per_minute 1.04

    def print_invoice(_pospaid, calls, month, year) do
      calls = Enum.reduce(calls, [], &filter_calls(&1, &2, month, year))
      value_spent = Enum.reduce(calls, 0, &(&1.value_spent + &2))

      %{
        calls: calls,
        value_spent: value_spent
      }
    end

    def make_call(subscriber_type, time_spent, date) do
      subscriber_type
      |> update_spent(time_spent)
      |> add_call(time_spent, date)
    end

    defp filter_calls(call, acc, month, year) do
      value_spent = call.time_spent * @price_per_minute
        if call.date.year == year and call.date.month == month do
          call = %{date: call.date, time_spent: call.time_spent, value_spent: value_spent}

          acc ++ [call]
        else
          acc
        end
    end

    defp update_spent(subscriber_type, time_spent) do
      spent = @price_per_minute * time_spent
      %{subscriber_type | spent: subscriber_type.spent + spent}
    end

    defp add_call(subscriber_type, time_spent, date) do
      call = Call.new(time_spent, date)
      {subscriber_type, call}
    end
  end
end
