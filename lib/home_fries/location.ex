defmodule HomeFries.Location do
  @moduledoc """
  This is the Location module which contains a data structure for
  holding `latitude` and `longitude` coordinates, and also contains
  some helper functions.
  """
  @moduledoc since: "0.1.0"

  @enforce_keys [:latitude, :longitude]
  defstruct [:latitude, :longitude]

  @type t :: %__MODULE__{latitude: float(), longitude: float()}

  @lookup %{
    0 => "0",
    1 => "1",
    2 => "2",
    3 => "3",
    4 => "4",
    5 => "5",
    6 => "6",
    7 => "7",
    8 => "8",
    9 => "9",
    10 => "b",
    11 => "c",
    12 => "d",
    13 => "e",
    14 => "f",
    15 => "g",
    16 => "h",
    17 => "j",
    18 => "k",
    19 => "m",
    20 => "n",
    21 => "p",
    22 => "q",
    23 => "r",
    24 => "s",
    25 => "t",
    26 => "u",
    27 => "v",
    28 => "w",
    29 => "x",
    30 => "y",
    31 => "z"
  }

  @doc """
  Creates a `Location` struct from a valid string.

  Valid strings are of the format "`latitude`, `longitude`",
  where `latitude` is a float between (inclusive) -90.0 and 90.0, and
  `longitude` is a float between (inclusive) -180.0 and 180.0.

  These values may be seperated by the following seperators: `[" ", ",", ", "]`.

  Returns a `Location` if the string contains a valid location, or `nil`
  otherwise.
  """
  @doc since: "0.1.0"
  @spec from_string(String.t()) :: nil | HomeFries.Location.t()
  def from_string(s) do
    parse_s =
      s
      |> String.split([", ", ",", " "], trim: true, parts: 2)
      |> Enum.map(&Float.parse/1)

    case parse_s do
      [{latitude, ""}, {longitude, ""}] -> from_floats(latitude, longitude)
      _ -> nil
    end
  end

  @doc """
  Converts a `Location` struct to a `Hash` struct using the Geohash
  algorithm.

  Always returns a `Hash` of the given `Location`.
  """
  @doc since: "0.1.0"
  @spec to_hash(HomeFries.Location.t(), integer) :: HomeFries.Hash.t()
  def to_hash(%HomeFries.Location{latitude: latitude, longitude: longitude}, precision) do
    alias HomeFries.Hash

    latpre = floor(precision * 5 / 2)
    longpre = ceil(precision * 5 / 2)
    latbin = to_binary(latitude, :latitude, latpre)
    longbin = to_binary(longitude, :longitude, longpre)

    binary_string =
      if rem(precision, 2) == 0 do
        combine_digits(Enum.reverse(latbin), Enum.reverse(longbin), [])
      else
        combine_digits(Enum.reverse(longbin), Enum.reverse(latbin), [])
      end

    hash =
      binary_string
      |> Enum.chunk_every(5)
      |> Enum.map_join(&(Integer.undigits(&1, 2) |> lookup_num()))

    %Hash{hash: hash}
  end

  @spec lookup_num(integer()) :: String.t()
  defp lookup_num(num) do
    Map.fetch!(@lookup, num)
  end

  @spec combine_digits([any()], [any()], [any()]) :: [any()]
  defp combine_digits(a, b, acc) do
    case {a, b} do
      {[x | xs], [y | ys]} -> combine_digits(xs, ys, [y | [x | acc]])
      {[x], []} -> [x | acc]
      _ -> acc
    end
  end

  defp to_binary(dec, :latitude, precision) do
    to_binary(dec, {-90.0, 0, 90.0}, precision)
  end

  defp to_binary(dec, :longitude, precision) do
    to_binary(dec, {-180.0, 0, 180.0}, precision)
  end

  defp to_binary(dec, vals, precision) do
    Stream.unfold({vals, precision}, fn
      {_, 0} ->
        nil

      {{min, mid, _max}, p} when min <= dec and dec <= mid ->
        {0, {{min, (min + mid) / 2, mid}, p - 1}}

      {{_min, mid, max}, p} ->
        {1, {{mid, (mid + max) / 2, max}, p - 1}}
    end)
  end

  @spec is_latitude(float()) :: bool()
  defguardp is_latitude(latitude) when latitude >= -90.0 and latitude <= 90.0

  @spec is_longitude(float()) :: bool()
  defguardp is_longitude(longitude) when longitude >= -180.0 and longitude <= 180.0

  @doc """
  Creates a `Location` struct from a pair of floats.

  The first value represents the `latitude` and the second the `longitude`.

  These values must follow the restrictions that the `latitude` is between (inclusive)
  -90.0 and 90.0, and the longitude` is between (inclusive) -180.0 and 180.0.

  Returns a `Location` if the two floats are valid, or `nil` otherwise.
  """
  @doc since: "0.1.0"
  @spec from_floats(float(), float()) :: nil | HomeFries.Location.t()
  def from_floats(latitude, longitude) when is_latitude(latitude) and is_longitude(longitude) do
    %HomeFries.Location{latitude: latitude, longitude: longitude}
  end

  def from_floats(_, _), do: nil
end
