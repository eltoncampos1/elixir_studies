defprotocol Subscriber do
  @fallback_to_any true
  def print_invoice(type, calls, month, year)
  def make_call(type, time_spent, date)
  def make_recharge(type, value, date)
end

defmodule Telephony.Core.Subscriber do
  @moduledoc false
  alias Telephony.Core.{Pospaid, Prepaid}
  defstruct full_name: nil, phone_number: nil, type: :prepaid, calls: []

  def new(%{type: :prepaid} = payload) do
    payload = %{payload | type: %Prepaid{}}
    struct(__MODULE__, payload)
  end

  def new(%{type: :pospaid} = payload) do
    payload = %{payload | type: %Pospaid{}}
    struct(__MODULE__, payload)
  end

  def make_call(%{type: type} = subscriber, time_spent, date) do
    case Subscriber.make_call(type, time_spent, date) do
      {:error, message} -> {:error, message}
      {type, call} -> %{subscriber | type: type, calls: subscriber.calls ++ [call]}
    end
  end

  def make_recharge(subscriber, value, date) do
    case Subscriber.make_recharge(subscriber.type, value, date) do
      {:error, message} ->
        {:error, message}

      type ->
        %{subscriber | type: type}
    end
  end

  def print_invoice(subscriber, calls, month, year) do
    invoice = Subscriber.print_invoice(subscriber.type, calls, month, year)

    %{
      subscriber: subscriber,
      invoice: invoice
    }
  end
end
