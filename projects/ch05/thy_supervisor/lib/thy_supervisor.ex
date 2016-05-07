defmodule ThySupervisor do
  use GenServer

  # Client API #

  def start_child(supervisor, child_spec) do
    GenServer.call(supervisor, {:start_child, child_spec})
  end

  def start_link(child_spec_list) do
    GenServer.start_link(__MODULE__, child_spec_list)
  end

  # Server API #

  def init(child_spec_list) do
    Process.flag(:trap_exit, true)
    state = start_children(child_spec_list)

    {:ok, state}
  end

  def handle_call({:start_child, child_spec}, _from, state) do
    case start_child(child_spec) do
      {:ok, pid} ->
        new_state = Map.put(state, child_spec, pid)
        {:reply, {:ok, pid}, new_state}

      :error ->
        {:reply, {:error, "error starting child", state}}
    end
  end

  # Helper Functions #
  defp start_children([child_spec | rest]) do
    case start_child(child_spec) do
      {:ok, pid} ->
        [{pid, child_spec} | start_children(rest)]
    end
  end

  defp start_children([]), do: []

  def start_child({module, function, args}) do
    case apply(module, function, args) do
      {:ok, pid} -> {:ok, pid}
      _ -> :error
    end
  end
end
