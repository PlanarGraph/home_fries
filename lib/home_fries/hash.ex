defmodule HomeFries.Hash do
  @moduledoc """
  This is the Hash module, which contains a data structure for holding
  valid hashes, provides functions to create them and convert them
  to their respective GPS locations.
  """
  @moduledoc since: "0.1.0"

  @enforce_keys [:hash]
  defstruct [:hash]

  @type t :: %__MODULE__{hash: String.t()}

  @lookup %{
    "0" => 0,
    "1" => 1,
    "2" => 2,
    "3" => 3,
    "4" => 4,
    "5" => 5,
    "6" => 6,
    "7" => 7,
    "8" => 8,
    "9" => 9,
    "b" => 10,
    "c" => 11,
    "d" => 12,
    "e" => 13,
    "f" => 14,
    "g" => 15,
    "h" => 16,
    "j" => 17,
    "k" => 18,
    "m" => 19,
    "n" => 20,
    "p" => 21,
    "q" => 22,
    "r" => 23,
    "s" => 24,
    "t" => 25,
    "u" => 26,
    "v" => 27,
    "w" => 28,
    "x" => 29,
    "y" => 30,
    "z" => 31
  }

  @doc """
  Converts the string to a `Hash` struct.

  Returns a `Hash` struct if successful, or `nil` if the string is invalid.
  """
  @doc since: "0.1.0"
  @spec from_string(String.t()) :: nil | HomeFries.Hash.t()
  def from_string(str) do
    if is_valid?(str), do: %HomeFries.Hash{hash: str}, else: nil
  end

  @doc """
  Converts the `Hash` to a string (binary) value.

  Returns the string contained in the `Hash` struct.
  """
  @doc since: "0.1.0"
  @spec to_string(HomeFries.Hash.t()) :: String.t()
  def to_string(%HomeFries.Hash{hash: hash}) do
    hash
  end

  @doc """
  Converts the `Hash` structure into a `Location` structure using
  the [Geohash](https://en.wikipedia.org/wiki/Geohash) algorithm.

  Returns a `Location` struct, as the given `Hash` is assumed to be
  always valid.
  """
  @doc since: "0.1.0"
  @spec to_location(HomeFries.Hash.t()) :: HomeFries.Location.t()
  def to_location(%HomeFries.Hash{hash: hash}) do
    alias HomeFries.Location

    {londigits, latdigits} = digits(hash)

    %Location{
      latitude: from_binary(latdigits, :latitude),
      longitude: from_binary(londigits, :longitude)
    }
  end

  @spec from_binary([integer()], :latitude | :longitude | {float(), float(), float()}) :: float()
  defp from_binary(digits, :latitude) do
    from_binary(digits, {-90.0, 0.0, 90.0})
  end

  defp from_binary(digits, :longitude) do
    from_binary(digits, {-180.0, 0.0, 180.0})
  end

  defp from_binary(digits, tuple) do
    {min, mid, max} =
      Enum.reduce(digits, tuple, fn
        0, {min, mid, _max} -> {min, (min + mid) / 2, mid}
        1, {_min, mid, max} -> {mid, (mid + max) / 2, max}
      end)

    rounded = Float.round(mid, 3)

    if rounded < min or rounded > max, do: Float.round(mid, 4), else: rounded
  end

  @spec digits(String.t()) :: {[integer()], [integer()]}
  defp digits(hash) do
    hash
    |> String.codepoints()
    |> Enum.flat_map(&(lookup_char(&1) |> Integer.digits(2) |> pad_width()))
    |> Enum.with_index()
    |> Enum.reverse()
    |> Enum.reduce({[], []}, fn
      {b, i}, {e, o} when rem(i, 2) == 0 -> {[b | e], o}
      {b, i}, {e, o} when rem(i, 2) == 1 -> {e, [b | o]}
    end)
  end

  @spec pad_width([integer()]) :: [integer()]
  def pad_width(digits) do
    Enum.take([0, 0, 0, 0, 0], 5 - length(digits)) ++ digits
  end

  @spec lookup_char(String.t()) :: integer()
  defp lookup_char(char) do
    Map.fetch!(@lookup, char)
  end

  @spec is_valid?(String.t()) :: bool()
  defp is_valid?(str) do
    str
    |> String.codepoints()
    |> Enum.all?(&String.contains?("0123456789bcdefghjkmnpqrstuvwxyz", &1))
  end
end
