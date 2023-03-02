defmodule Telephony.Core do
  @moduledoc false
  alias __MODULE__.Subscriber
  @allowed_types [:prepaid, :pospaid]

  def create_subscriber(subscribers, %{type: type} = payload)
      when type in @allowed_types do
    case Enum.find(subscribers, &(&1.phone_number == payload.phone_number)) do
      %__MODULE__.Subscriber{} ->
        {:error, "Subscriber `#{payload.phone_number}`, already exists"}

      _ ->
        subscriber = Subscriber.new(payload)
        [subscriber] ++ subscribers
    end
  end

  def create_subscriber(_subscribers, _payload),
    do: {:error, "Only 'prepaid' or ''postpaid' are accepted"}

  def search_subscriber(subscribers, phone_number) do
    Enum.find(subscribers, &(&1.phone_number == phone_number))
  end

  def make_recharge(subscribers, phone_number, value, date) do
    perform = fn subscriber ->
      subscribers = List.delete(subscribers, subscriber)
      result = Subscriber.make_recharge(subscriber, value, date)
      update_subscriber(subscribers, result)
    end

    execute_operation(subscribers, phone_number, perform)
  end

  def update_subscriber(subscribers, {:error, _message} = err) do
    {subscribers, err}
  end

  def update_subscriber(subscribers, subscriber) do
    {subscribers ++ [subscriber], subscriber}
  end

  def make_call(subscribers, phone_number, time_spent, date) do
    perform = fn subscriber ->
      subscribers = List.delete(subscribers, subscriber)
      result = Subscriber.make_call(subscriber, time_spent, date)
      update_subscriber(subscribers, result)
    end

    execute_operation(subscribers, phone_number, perform)
  end

  def print_invoice(subscribers, phone_number, month, year) do
    perform = &Subscriber.print_invoice(&1, &1.calls, month, year)
    execute_operation(subscribers, phone_number, perform)
  end

  def print_invoices(subscribers, month, year) do
    subscribers
    |> Enum.map(&Subscriber.print_invoice(&1, &1.calls, year, month))
  end

  defp execute_operation(subscribers, phone_number, func) do
    subscribers
    |> search_subscriber(phone_number)
    |> then(fn subscriber ->
      if is_nil(subscriber) do
        subscribers
      else
        func.(subscriber)
      end
    end)
  end
end
