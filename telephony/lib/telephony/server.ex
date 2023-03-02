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
end
