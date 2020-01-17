defmodule HomeFries do
  @moduledoc """
  Main api for HomeFries. Contains methods to convert
  strings of hashes to strings of locations and vice versa.
  """
  @moduledoc since: "0.1.0"

  alias HomeFries.Hash
  alias HomeFries.Location

  @doc """
  Converts a hash string to a location string.

  Returns a string containing the latitude and longitude of
  the geohash or `nil` if the input string is invalid.

  ## Examples
    iex> HomeFries.hash_to_location("u4pruydqqvj")
    "57.64911063, 10.40743969"
  """
  @doc since: "0.1.0"
  @spec hash_to_location(String.t()) :: nil | String.t()
  def hash_to_location(input) do
    hash =
      cond do
        is_binary(input) -> Hash.from_string(input)
        true -> nil
      end

    case hash do
      nil -> nil
      hash -> hash |> Hash.to_location() |> Location.to_string()
    end
  end

  @doc """
  Converts a location string or tuple to a geohash. Location
  values should be ordered such that latitude preceeds longitude.

  Returns a string containing the geohash of the given coordinates
  or `nil` if the input is invalid.

  ## Examples
    iex> HomeFries.location_to_hash("57.64911, 10.40744", 11)
    "u4pruydqqvj"

    iex> HomeFries.location_to_hash({57.64911, 10.40744}, 11)
    "u4pruydqqvj"
  """
  @doc since: "0.1.0"
  @spec location_to_hash(binary | {float, float}, integer) :: nil | String.t()
  def location_to_hash(input, precision \\ 12) do
    location =
      cond do
        is_binary(input) -> Location.from_string(input)
        is_tuple(input) -> Location.from_pair(input)
        true -> nil
      end

    case location do
      nil -> nil
      _ -> location |> Location.to_hash(precision) |> Hash.to_string()
    end
  end
end
