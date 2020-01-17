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
  """
  @doc since: "0.1.0"
  @spec hash_to_location(String.t()) :: nil | String.t()
  def hash_to_location(input) do
    case Hash.from_string(input) do
      nil -> nil
      hash -> hash |> Hash.to_location() |> Location.to_string()
    end
  end

  @doc """
  Converts a location string or tuple to a geohash. Location
  values should be ordered such that latitude preceeds longitude.

  Returns a string containing the geohash of the given coordinates
  or `nil` if the input is invalid.
  """
  @doc since: "0.1.0"
  @spec location_to_hash(binary | {float, float}) :: nil | String.t()
  def location_to_hash(input) when is_binary(input) do
    case Location.from_string(input) do
      nil -> nil
      location -> location |> Location.to_hash(11) |> Hash.to_string()
    end
  end

  def location_to_hash(input) when is_tuple(input) do
    case Location.from_pair(input) do
      nil -> nil
      location -> location |> Location.to_hash(11) |> Hash.to_string()
    end
  end

  def location_to_hash(_), do: nil

  @doc """
  Converts a location given as a pair of floats to a geohash. Location
  values should be ordered such that latitude preceeds longitude.

  Returns a string containing the geohash of the given coordinates
  or `nil` if the input is invalid.
  """
  @doc since: "0.1.0"
  @spec location_to_hash(float, float) :: nil | String.t()
  def location_to_hash(latitude, longitude) when is_float(latitude) and is_float(longitude) do
    location_to_hash({latitude, longitude})
  end

  def location_to_hash(_, _), do: nil
end
