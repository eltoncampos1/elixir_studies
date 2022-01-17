defmodule Account do
  defstruct user: User, balance: 1000

  def register(user), do: %__MODULE__{user: user}

  def transfer(accounts, from, to, value) do
    from = Enum.find(accounts, fn acc -> acc.user.email == from.user.email end)

    cond do
      validate_balance(from.balance, value) -> {:error, "Insufficient funds"}
      true ->
        to = Enum.find(accounts, fn acc -> acc.user.email == to.user.email end)
        from = %Account{from | balance: from.balance - value}
        to = %Account{to | balance: to.balance + value}
        [from, to]
    end
  end

  def withdraw(account, value) do
    cond do
      validate_balance(account.balance, value) -> {:error, "Insufficient funds"}
      true ->
        account = %Account{account | balance: account.balance - value}
        {:ok, account, "Withdrawal completed successfully!"}
    end
  end

  defp validate_balance(balance, value), do: balance < value

end
