defmodule Ring do
  def create_processes(n) do
    1..n |> Enum.map(fn(_) -> spawn(fn -> loop end) end)
  end

  defp loop do
    receive do
      {:link_to, link_to} when is_pid(link_to) ->
        Process.link(link_to)
        loop

      :trap_exit ->
        Process.flag(:trap_exit, true)
        loop

      :crash -> 1 / 0

      {:EXIT, pid, reason} ->
        "#{inspect self}: received {:EXIT, #{inspect pid}, #{inspect reason}}"
        loop
    end
  end

  def link_processes(procs) do
    link_processes(procs, [])
  end

  def link_processes([proc_1, proc_2 | rest], linked_processes) do
    send(proc_1, {:link_to, proc_2})
    link_processes([proc_2 | rest], [proc_1, linked_processes])
  end

  def link_processes([proc | []], linked_processes) do
    first_process = linked_processes |> List.last
    send(proc, {:link_to, first_process})
    :ok
  end
end
