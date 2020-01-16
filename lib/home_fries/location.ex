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
