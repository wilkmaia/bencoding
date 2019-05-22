defmodule BencodingTest do
  use ExUnit.Case
  doctest Bencoding

  test "greets the world" do
    assert Bencoding.hello() == :world
  end
end
