defmodule Call do
  defstruct date: nil, duration: nil

  def register(subscriber, date, duration) do
    updated_subscriber = %Subscriber{
      subscriber
      | calls: subscriber.calls ++ [%__MODULE__{date: date, duration: duration}]
    }

    Subscriber.update(subscriber.number, updated_subscriber)
  end
end
