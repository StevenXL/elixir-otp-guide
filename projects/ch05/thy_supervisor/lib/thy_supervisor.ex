defmodule ThySupervisor do
  use GenServer

  # Client API #

  def start_link(child_spec_list) when is_list(child_spec_list) do
    GenServer.start_link(__MODULE__, child_spec_list)
  end

  def start_child(supervisor, child_spec) when is_pid(supervisor) do
    GenServer.call(supervisor, {:start_child, child_spec})
  end

  def terminate_child(supervisor, child) when is_pid(supervisor) do
    GenServer.call(supervisor, {:terminate_child, child})
  end

  def restart_child(supervisor, child) when is_pid(supervisor) do
    GenServer.call(supervisor, {:restart_child, child})
  end

  def count_children(supervisor) when is_pid(supervisor) do
    GenServer.call(supervisor, :count_children)
  end

  def which_children(supervisor) when is_pid(supervisor) do
    GenServer.call(supervisor, :which_children)
  end

  # Server API #

  def init(child_spec_list) do
    Process.flag(:trap_exit, true)
    state = child_spec_list |> start_children |> Enum.into(%{})

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

  def handle_call({:terminate_child, child}, _from, state) do
    case terminate(child) do
      :ok -> {:reply, :ok, Map.delete(state, child)}
      _ -> {:reply, {:error, "error terminating child"}, state}
    end
  end

  def handle_call({:restart_child, child}, _from, state) do
    case terminate(child) do
      :ok ->
        child_spec = Map.get(state, child)
        {:ok, pid} = start_child(child_spec)
        state = Map.delete(state, child) |> Map.put(pid, child_spec)
        {:reply, {:ok, pid}, state}
      _ -> {:reply, "error restarting child", state}
    end
  end

  def handle_call(:count_children, _from, state) do
    {:reply, Enum.count(state), state}
  end

  def handle_call(:which_children, _from, state) do
    {:reply, state, state}
  end

  def handle_info({:EXIT, from, :killed}, state) do
    {:noreply, Map.delete(state, from)}
  end

  # Helper Functions #
  defp start_children([child_spec | rest]) do
    case start_child(child_spec) do
      {:ok, pid} ->
        [{pid, child_spec} | start_children(rest)]
    end
  end

  defp start_children([]), do: []

  defp start_child({module, function, args}) do
    case apply(module, function, args) do
      {:ok, pid} -> {:ok, pid}
      _ -> :error
    end
  end

  defp terminate(pid) do
    # NOTE: Supervisor's state not affected. 'pid' will send exit signal
    Process.exit(pid, :kill)
    :ok
  end
end
