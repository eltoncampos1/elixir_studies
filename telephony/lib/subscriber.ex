defmodule Subscriber do
  defstruct name: nil, number: nil, cpf: nil, plan: nil

  @subscribers%{
    :prepaid => "plans/pre.txt",
    :postpaid => "plans/post.txt"
  }

  def register(name, number, cpf, plan) do
    case find_subscriber(number) do
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
    case File.read(@subscribers[plan]) do
      {:ok, subscribers } ->
        subscribers
          |> :erlang.binary_to_term
      {:error, :enoent} ->
        {:error, "Invalid File"}
    end

  end

  def find_subscriber(number, key \\ :all), do: find(number, key)

  defp find(number, :prepaid), do: filter(prepaid_subscribers(), number)
  defp find(number, :postpaid), do: filter(postpaid_subscribers(), number)
  defp find(number, :all), do: filter(subscribers(), number)

  defp filter(list, number), do: Enum.find(list, &(&1.number == number))

  def prepaid_subscribers(), do: read(:prepaid)
  def postpaid_subscribers(), do: read(:postpaid)

  def subscribers, do: read(:prepaid) ++ read(:postpaid)
end
