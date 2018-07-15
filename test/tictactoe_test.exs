defmodule TictactoeTest do
  use ExUnit.Case
  doctest Tictactoe

  test "greets the world" do
    assert Tictactoe.hello() == :world
  end
end
