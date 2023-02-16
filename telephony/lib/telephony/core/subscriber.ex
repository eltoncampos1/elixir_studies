defmodule Telephony.Core.Subscriber do
  @moduledoc false
  alias Telephony.Core.{Pospaid, Prepaid}
  defstruct full_name: nil, phone_number: nil, subscriber_type: :prepaid, calls: []

  def new(%{subscriber_type: :prepaid} = payload) do
    payload = %{payload | subscriber_type: %Prepaid{}}
    struct(__MODULE__, payload)
  end

  def new(%{subscriber_type: :pospaid} = payload) do
    payload = %{payload | subscriber_type: %Pospaid{}}
    struct(__MODULE__, payload)
  end

  def make_call(%{subscriber_type: subscriber_type} = subscriber, time_spent, date)
      when subscriber_type.__struct__ == Pospaid do
    Pospaid.make_call(subscriber, time_spent, date)
  end

  def make_call(%{subscriber_type: subscriber_type} = subscriber, time_spent, date)
      when subscriber_type.__struct__ == Prepaid do
    Prepaid.make_call(subscriber, time_spent, date)
  end

  def make_recharge(%{subscriber_type: subscriber_type} = subscriber, value, date)
      when subscriber_type.__struct__ == Prepaid do
    Prepaid.make_recharge(subscriber, value, date)
  end

  def make_recharge(_subscriber, _value, _date),
    do: {:error, "Only a prepaid can make a recharge"}
end
