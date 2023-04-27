defmodule Telephony.Server do
  @moduledoc """
  #{__MODULE__} Genserver impl
  """
  @behaviour GenServer

  alias Telephony.Core

  def start_link(server_name) do
    GenServer.start_link(__MODULE__, [], name: server_name)
  end

  def init(subscibers), do: {:ok, subscibers}

  def handle_call({:create_subscriber, payload}, _from, subscribers) do
    case Core.create_subscriber(subscribers, payload) do
      {:error, _} = err -> {:reply, err, subscribers}
      subscribers -> {:reply, subscribers, subscribers}
    end
  end

  def handle_call({:search_subscriber, phone_number}, _from, subscribers) do
    subscriber = Core.search_subscriber(subscribers, phone_number)
    {:reply, subscriber, subscribers}
  end

  def handle_call({:make_call, phone_number, time_spent, date}, _from, subscribers) do
    case Core.make_call(subscribers, phone_number, time_spent, date) do
      {:error, _} = err -> {:reply, err, subscribers}
      {subscribers, subscriber} -> {:reply, subscriber, subscribers}
    end
  end

  def handle_call({:print_invoice, phone_number, month, year}, _from, subscribers) do
    case Core.print_invoice(subscribers, phone_number, month, year) do
      {:error, _} = err -> {:reply, err, subscribers}
      invoice -> {:reply, invoice, subscribers}
    end
  end

  def handle_cast({:make_recharge, phone_number, value, date}, subscribers) do
    case Core.make_recharge(subscribers, phone_number, value, date) do
      {:error, _} -> {:noreply, subscribers}
      {subscribers, _} -> {:noreply, subscribers}
    end
  end
end
