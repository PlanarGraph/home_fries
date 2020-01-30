defmodule HomeFriesTest do
  use ExUnit.Case
  doctest HomeFries

  alias HomeFries.Location
  alias HomeFries.Hash

  test "Can convert location to hash" do
    assert Location.to_hash(%Location{latitude: 57.64911, longitude: 10.40744}, 11) ==
             %Hash{hash: "u4pruydqqvj"}
  end

  test "Can convert hash to location" do
    assert %Location{latitude: 57.64911063, longitude: 10.40743969} ==
             Hash.to_location(%Hash{hash: "u4pruydqqvj"})
  end

  test "Api can convert location string to hash" do
    assert HomeFries.encode("57.64911, 10.40744", 11) == "u4pruydqqvj"
  end

  test "Api can convert location tuple to hash" do
    assert HomeFries.encode({57.64911, 10.40744}, 11) == "u4pruydqqvj"
  end

  test "Api can convert hash to location pair" do
    assert HomeFries.decode("u4pruydqqvj") == "57.64911063, 10.40743969"
  end
end
