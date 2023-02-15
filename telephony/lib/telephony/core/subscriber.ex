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
end
