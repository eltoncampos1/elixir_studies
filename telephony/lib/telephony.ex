defmodule Telephony do

  def start do
    File.write("plans/pre.txt", :erlang.term_to_binary([]))
    File.write("plans/post.txt", :erlang.term_to_binary([]))
  end

  def register_subscriber(name, number, cpf, plan \\ :prepaid) do
    Subscriber.register(name, number, cpf, plan)
  end
end
