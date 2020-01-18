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
    hash
    # Get the codepoints of the hash.
    |> String.codepoints()
    # Convert characters to their binary representation and join the lists.
    |> Enum.flat_map(&to_binary/1)
    # Index each bit.
    |> Enum.with_index()
    # Split the list into even indexed bits and odd indexed bits.
    |> List.foldr({[], []}, fn
      {b, i}, {evens, odds} when rem(i, 2) == 0 -> {[b | evens], odds}
      {b, i}, {evens, odds} when rem(i, 2) == 1 -> {evens, [b | odds]}
    end)
    # Convert the bit strings into latitude and longitude coordinates.
    |> from_bits(String.length(hash))
    # Use the location module to verify and create a Location struct.
    |> HomeFries.Location.from_pair()
  end

  defp from_bits({longitude, latitude}, hash_length) do
    {lat_pre, lon_pre} = get_precision(hash_length - 1)
    lat = from_bits(latitude, {-90.0, 0.0, 90.0}) |> Float.round(lat_pre)
    lon = from_bits(longitude, {-180.0, 0.0, 180.0}) |> Float.round(lon_pre)

    {lat, lon}
  end

  defp from_bits(digits, tuple) do
    {_min, mid, _max} =
      Enum.reduce(digits, tuple, fn
        0, {min, mid, _max} -> {min, (min + mid) / 2, mid}
        1, {_min, mid, max} -> {mid, (mid + max) / 2, max}
      end)

    mid
  end

  # To get the precision for the latitude and longitude from the hash length.
  defp get_precision(num) do
    Stream.unfold(0, fn
      x -> {[{x, x}, {x + 1, x + 1}, {x + 2, x + 2}, {x + 3, x + 2}], x + 3}
    end)
    |> Enum.at(div(num, 4))
    |> Enum.at(rem(num, 4))
  end

  defp to_binary(s) do
    s
    # Lookup the character conversion in the lookup table.
    |> lookup_char()
    # Convert the integer to its binary representation.
    |> Integer.digits(2)
    # Pad the binary list to 5 bits.
    |> pad_width()
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
    |> String.match?(~r/^([0-9]|[b-h]|[j-k]|[m-n]|[p-z]){1,12}$/)
  end
end
