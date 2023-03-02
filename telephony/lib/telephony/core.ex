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
    subscribers
    |> search_subscriber(phone_number)
    |> then(fn subscriber ->
      if is_nil(subscriber) do
        subscribers
      else
        subscribers = List.delete(subscribers, subscriber)
        result = Subscriber.make_recharge(subscriber, value, date)
        update_subscriber(subscribers, result)
      end
    end)
  end

  def update_subscriber(subscribers, {:error, _message} = err) do
    {subscribers, err}
  end

  def update_subscriber(subscribers, subscriber) do
    {subscribers ++ [subscriber], subscriber}
  end
end
