defmodule Subscriber do
  defstruct name: nil, number: nil, cpf: nil, plan: nil

  @subscribers%{
    :prepaid => "plans/pre.txt",
    :postpaid => "plans/post.txt"
  }

  def register(name, number, cpf, plan) do
    case find_subscriber_by_number(number) do
      nil ->
      read(plan) ++ [%__MODULE__{name: name, number: number, cpf: cpf, plan: plan}]
        |> :erlang.term_to_binary()
        |> write(plan)

        {:ok, "Subscriber #{name} has been successfully registered"}
        _subscriber ->
          {:error, "Subscriber with this number already registered"}
    end
    end


  defp write(subscribers_list, plan) do
    File.write!(@subscribers[plan], subscribers_list)
  end

  def read(plan) do
    {:ok, subscribers } = File.read(@subscribers[plan])
    subscribers
      |> :erlang.binary_to_term
  end

  def find_subscriber_by_number(number) do
    read(:prepaid) ++ read(:postpaid)
      |> Enum.find(fn sub -> sub.number == number end)
  end
end
