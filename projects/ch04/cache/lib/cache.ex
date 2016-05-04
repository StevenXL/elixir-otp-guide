defmodule Cache do
  use GenServer

  ## Client API ##

  def clear do
    GenServer.cast(:cache, :clear)
  end

  def delete(key) do
    GenServer.cast(:cache, {:delete, key})
  end

  def exist?(key) do
    GenServer.call(:cache, {:exist, key})
  end

  def read(key) do
    GenServer.call(:cache, {:read, key})
  end

  def start do
    GenServer.start(__MODULE__, [], name: :cache)
  end

  def write(key, value) do
    GenServer.cast(:cache, {:write, key, value})
  end

  ## Server API ##

  def init(_) do
    {:ok, %{}}
  end

  def handle_call({:exist, key}, _from, dict) do
    {:reply, Map.has_key?(dict, key), dict}
  end

  def handle_call({:read, key}, _from, dict) do
    {:reply, Map.get(dict, key), dict}
  end

  def handle_cast(:clear, dict) do
    {:noreply, %{}}
  end

  def handle_cast({:delete, key}, dict) do
    {:noreply, Map.delete(dict, key)}
  end

  def handle_cast({:write, key, value}, dict) do
    {:noreply, Map.put(dict, key, value)}
  end
end
