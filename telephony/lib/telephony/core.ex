defmodule Telephony.Core do
  @moduledoc false
  alias __MODULE__.Subscriber
  @allowed_types [:prepaid, :postpaid]

  def create_subscriber(subscribers, %{subscriber_type: type} = payload)
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
end
