defmodule ThyWorker do
  use GenServer

  ## Client API ##
  def start_link do
    GenServer.start_link(__MODULE__, [])
  end

  ## Server API ##

  def init(_) do
    {:ok, nil}
  end

  ## Helper Functions ##
end
