defmodule SingletonTest do
  use ExUnit.Case
  doctest Singleton

  test "greets the world" do
    assert Singleton.hello() == :world
  end
end
