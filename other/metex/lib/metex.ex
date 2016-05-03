defmodule Metex do
  def temperatures_for(cities) do
    coordinator_pid = spawn(Metex.Coordinator, :loop, [[], Enum.count(cities)])

    Enum.map(cities, fn(city) ->
      worker_pid = spawn(Metex.Worker, :loop, [])
      send(worker_pid, {coordinator_pid, city})
    end)
  end

  def temperature_for(city) do
      worker_pid = spawn(Metex.Worker, :loop, [])
      send(worker_pid, {self, city})
  end
end
