defmodule Telephony do

  def register_subscriber(name, number, cpf) do
    Subscriber.register(name, number, cpf)
  end
end
