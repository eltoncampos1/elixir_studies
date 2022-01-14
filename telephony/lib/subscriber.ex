defmodule Subscriber do
  @moduledoc """
  Module for register Subscribers with tipes `prepaid` and `postpaid`

  the main function is `register/4`
  """

  defstruct name: nil, number: nil, cpf: nil, plan: nil

  @subscribers%{
    :prepaid => "plans/pre.txt",
    :postpaid => "plans/post.txt"
  }

  @doc """
  Function to register subscribers `prepaid` or `postpaid`

  ## Function parameters

   - name: subscriber name
   - number: is unique, if is already registered return an error
   - cpf: subscriber cpf
   - plan: optional (`prepaid` or `postpaid`), by default is `prepaid`

  ## Example

      iex> Subscriber.register("user_test", "1234", "56789", :prepaid)
      {:ok, "Subscriber user_test has been successfully registered"}
  """

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

  def delete(number) do
    subscriber = find_subscriber(number)

    result_delete = subscribers()
      |> List.delete(subscriber)
      |> :erlang.term_to_binary()
      |> write(subscriber.plan)
      {result_delete, "Subscriber #{subscriber.name} successfully deleted."}
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

  @doc """
  Function find subscribers

  ## Function parameters

   - number: subscriber number
   - key: optional (`prepaid` or `postpaid`), by default is all

  ## Example

      iex> Subscriber.register("user_test", "1234", "56789", :prepaid)
      {:ok, "Subscriber user_test has been successfully registered"}
      iex> Subscriber.register("user_test2", "4567", "56789", :postpaid)
      {:ok, "Subscriber user_test2 has been successfully registered"}
      iex> Subscriber.find_subscriber("1234")
      %Subscriber{cpf: "56789", name: "user_test", number: "1234", plan: :prepaid}
      iex> Subscriber.find_subscriber("4567")
      %Subscriber{cpf: "56789", name: "user_test2", number: "4567", plan: :postpaid}

  """

  def find_subscriber(number, key \\ :all), do: find(number, key)

  defp find(number, :prepaid), do: filter(prepaid_subscribers(), number)
  defp find(number, :postpaid), do: filter(postpaid_subscribers(), number)
  defp find(number, :all), do: filter(subscribers(), number)

  defp filter(list, number), do: Enum.find(list, &(&1.number == number))

  def prepaid_subscribers(), do: read(:prepaid)
  def postpaid_subscribers(), do: read(:postpaid)

  def subscribers, do: read(:prepaid) ++ read(:postpaid)
end
