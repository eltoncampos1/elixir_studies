defmodule Transaction do
  defstruct date: Date.utc_today(), type: nil, value: 0, from: nil, to: nil

  @transactions "transactions.txt"

  def record(type, from, value, date, to \\ nil) do
    transactions =
      find_transactions() ++
        [%__MODULE__{type: type, from: from, value: value, date: date, to: to}]

    File.write(@transactions, :erlang.term_to_binary(transactions))
  end

  def find_all(), do: find_transactions()

  def find_by_year(year), do: Enum.filter(find_transactions(), &(&1.date.year == year))

  def find_by_month(year, month),
    do: Enum.filter(find_transactions(), &(&1.date.year == year && &1.date.month == month))

  def find_by_date(date), do: Enum.filter(find_transactions(), &(&1.date == date))

  def calculate(transactions) do
    {transactions, Enum.reduce(transactions, 0, fn x, acc -> acc + x.value end)}
  end

  def calculate_by_month(year, month) do
    find_by_month(year, month)
    |> calculate()
  end

  def calculate_by_year(year) do
      find_by_year(year)
    |> calculate()
  end

  def calculate_by_date(date) do
    find_by_date(date)
    |> calculate()
  end

  def find_transactions() do
    {:ok, binary} = File.read(@transactions)

    binary
    |> :erlang.binary_to_term()
  end
end
