defmodule PeekTakehomeTest do
  use ExUnit.Case
  doctest PeekTakehome

  test "greets the world" do
    assert PeekTakehome.hello() == :world
  end
end
