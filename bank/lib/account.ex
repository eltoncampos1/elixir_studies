defmodule Account do
  defstruct user: User, balance: 1000

  @accounts "accounts.txt"

  def register(user) do
    case find_by_email(user.email) do
      nil ->
        binary = [%__MODULE__{user: user}] ++ find_accounts()
        |> :erlang.term_to_binary()
        File.write(@accounts, binary)
      _ -> {:error, "User already registered."}
    end

  end

  def transfer(from, to, value) do
    from = find_by_email(from)
    to = find_by_email(to)

    cond do
      validate_balance(from.balance, value) -> {:error, "Insufficient funds"}
      true ->
        accounts = delete([from, to])
        from = %Account{from | balance: from.balance - value}
        to = %Account{to | balance: to.balance + value}
        accounts = accounts ++ [from, to]
        Transaction.record("transfer", from.user.email, value, Date.utc_today(), to.user.email)
        File.write(@accounts, :erlang.term_to_binary(accounts))

    end
  end

  def withdraw(account, value) do
    account = find_by_email(account)
    cond do
      validate_balance(account.balance, value) -> {:error, "Insufficient funds"}
      true ->
        account = %Account{account | balance: account.balance - value}
        {:ok, account, "Withdrawal completed successfully!"}
    end
  end

  def find_accounts do
    {:ok, binary} = File.read(@accounts)
    :erlang.binary_to_term(binary)
  end

  def delete(delete_accounts) do
    Enum.reduce(delete_accounts, find_accounts(), fn c, acc -> List.delete(acc, c)end)
  end

  defp validate_balance(balance, value), do: balance < value

  defp find_by_email(email), do:  Enum.find(find_accounts(), &(&1.user.email == email))

end
