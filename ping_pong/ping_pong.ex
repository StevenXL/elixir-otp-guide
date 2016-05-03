defmodule PingPong do
  def start do
    {:ok, ping, pong}
  end

  def ping do
    spawn(PingPong, :do_ping, [])
  end

  def do_ping do
    receive do
      {caller_pid, :ping} -> send(caller_pid, :pong)
      _ -> nil
    end

    do_ping
  end

  def pong do
    spawn(PingPong, :do_pong, [])
  end

  def do_pong do
    receive do
      {caller_pid, :pong} -> send(caller_pid, :ping)
      _ -> nil
    end

    do_pong
  end
end

