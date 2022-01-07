defmodule Cards do
  @moduledoc """
  Provides methos for creating and handling a deck of cards
  """

  @doc """
  returns a list of strings representing a deck of playing cards
  """
  def create_deck do
     values = ["Ace", "Two", "Three", "Four", "Five"]
     suits = [ "Spades", "Clubs", "Hearths", "Diamonds"]

    for suit <- suits, value <- values do
        "#{value} of #{suit}"
     end

  end

  def shuffle(deck) do
    Enum.shuffle(deck)
  end

  @doc """
    Determines whether deck contains a given card

  ## Examples

        iex> deck = Cards.create_deck
        iex> Cards.contains?(deck, "Ace of Spades")
        true

  """

  def contains?(deck,card) do
    Enum.member?(deck,card)
  end

  @doc """
    Divids aa deck into a hand an reminder of the deck.
    the `hand size` argument indicates how many cards
    should be in the hand.

  ## Examples

        iex> deck = Cards.create_deck
        iex> {hand, _} = Cards.deal(deck, 1)
        iex> hand
        ["Ace of Spades"]

  """
  def deal(deck, hand_size) do
    Enum.split(deck,hand_size)
  end

  def save(deck, filename) do
    binary = :erlang.term_to_binary(deck)
    File.write(filename, binary)
  end


  def load(filename) do
    case File.read(filename) do
     {:ok, binary} -> :erlang.binary_to_term binary
      {:error, _} -> "File does not exits"
    end
  end

  def create_hand(hand_size) do
     Cards.create_deck()
     |> Cards.shuffle()
     |> Cards.deal(hand_size)
  end
end
