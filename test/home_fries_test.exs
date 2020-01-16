defmodule HomeFriesTest do
  use ExUnit.Case
  doctest HomeFries

  test "greets the world" do
    assert HomeFries.hello() == :world
  end
end
