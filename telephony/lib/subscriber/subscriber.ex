defmodule Subscriber.Subscriber do
  @moduledoc false

  defstruct full_name: nil, id: nil, phone_number: nil, subscriber_type: :prepaid
  def new(payload) do
    struct(__MODULE__, payload)
  end
end
