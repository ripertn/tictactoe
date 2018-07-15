defmodule Tictactoe do
  use GenServer

  def start_link(opts \\ []), do: GenServer.start_link(__MODULE__, :ok, opts)
  def play(server, player, coord), do: GenServer.call(server, {:play, player, coord})
  def getState(server), do: GenServer.call(server, {:getState})
  def stop(server), do: GenServer.stop(server)

  def init(:ok) do
    board = [[" "," "," "],[" "," "," "],[" "," "," "]]
    last_player = :player1
    schedule_work()
    {:ok, {board, last_player, 0}}
  end


  def handle_call({:getState}, _from, state), do: {:reply, state, state}
  def handle_call({:play, player, coord}, _from, {board, last_player, opt}) do
    coord = validmove?(coord, board)
    case {player, coord} do
      {^last_player,_} -> {:reply, "It is not the turn of this player", {board, last_player, opt}}
      {_, {false, _}} -> {:reply, "this move is not allowed", {board, last_player, opt}}
      {player, {_, coord}} -> 
        board = updateBoard(coord, board, pawn(player))
        {:reply, "new move", {board, player, opt}}
      _ -> {:reply, "unhandled case", {board, last_player, opt}}
    end
  end

  def handle_info(:work, {board, last_player, time} = state) do
    display(state)
    schedule_work()
    {:noreply, {board, last_player, time+100}}
  end

  def handle_info(_msg, state), do: {:noreply, state}

  defp schedule_work(), do: Process.send_after(self(), :work, 100) # every 100ms

  def display({board, last_player , time}) do
    line = "-------------\n"
    IO.puts("chrono: " <> to_string(time) <> "ms, waiting after " <> to_string(nextPlayer(last_player)))
    IO.puts(line <> (Enum.map(board, &("| " <> Enum.join(&1, " | ") <> " |\n")) |> Enum.join(line)) <> line)
  end

  def updateBoard({x,y}, board, val) do
    List.replace_at(board, y, List.replace_at(Enum.at(board, y), x, val) )
  end

  def validmove?({x,y}=coord, board) do
    (Enum.at(board, y) |> Enum.at(x)) == " " && {true,coord} || {false,coord}
  end

  def pawn(:player1), do: :o
  def pawn(:player2), do: :x
  def pawn(_), do: :nok
  def nextPlayer(:player1), do: :player2
  def nextPlayer(:player2), do: :player1
  def nextPlayer(_), do: :nok
end