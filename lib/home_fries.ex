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
      iex> HomeFries.decode("u4pruydqqvj")
      "57.64911063, 10.40743969"
  """
  @doc since: "0.1.0"
  @spec decode(String.t()) :: nil | String.t()
  def decode(input) do
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
      iex> HomeFries.encode("57.64911, 10.40744", 11)
      "u4pruydqqvj"

      iex> HomeFries.encode({57.64911, 10.40744}, 11)
      "u4pruydqqvj"
  """
  @doc since: "0.1.0"
  @spec encode(binary | {float, float}, integer | nil) :: nil | String.t()
  def encode(input, precision \\ nil) do
    location =
      cond do
        is_binary(input) -> Location.from_string(input)
        is_tuple(input) -> Location.from_pair(input)
        true -> nil
      end

    case {location, precision} do
      {nil, _} ->
        nil

      # When no precision is given, converge until a sufficient value is found.
      {_, nil} ->
        lat_pre = get_precision(location.latitude)
        lon_pre = get_precision(location.longitude)

        1..12
        |> Stream.map(&(location |> Location.to_hash(&1)))
        |> Enum.find(fn hash ->
          hash_location = hash |> Hash.to_location()
          hash_lat = Float.round(hash_location.latitude, lat_pre)
          hash_lon = Float.round(hash_location.longitude, lon_pre)

          %Location{latitude: hash_lat, longitude: hash_lon} == location
        end)

      _ ->
        location
        |> Location.to_hash(precision)
        |> Hash.to_string()
    end
  end

  defp get_precision(x) do
    x
    |> Float.to_string()
    |> String.split(".")
    |> tl()
    |> hd()
    |> String.length()
  end
end
