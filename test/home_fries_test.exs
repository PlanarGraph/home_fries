defmodule HomeFriesTest do
  use ExUnit.Case
  doctest HomeFries

  test "greets the world" do
    assert HomeFries.hello() == :world
  end

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
end
