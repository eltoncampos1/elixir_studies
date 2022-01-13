defmodule Subscriber do
  defstruct name: nil, number: nil, cpf: nil

  @filename "subscribers.txt"

    def register(name, number, cpf) do
      read() ++ [%__MODULE__{name: name, number: number, cpf: cpf}]
        |> :erlang.term_to_binary()
        |> write()
    end

    defp write(subscribers_list) do
      File.write!(@filename, subscribers_list)
    end

    defp read() do
      {:ok, subscribers } = File.read(@filename)
      subscribers
        |> :erlang.binary_to_term
    end
end
