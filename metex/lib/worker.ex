defmodule Metex.Worker do
  use GenServer

  ## Client API ##

  def get_stats(pid) do
    GenServer.call(pid, :get_stats)
  end

  def reset_stats(pid) do
    GenServer.cast(pid, :reset_stats)
  end

  def start do
    GenServer.start(__MODULE__, [])
  end

  def stop(pid) do
    GenServer.cast(pid, :stop)
  end

  def temperature_for(pid, location) do
    GenServer.call(pid, {:weather, location})
  end

  ## Server API ##

  def handle_call(:get_stats, _from, stats) do
    {:reply, stats, stats}
  end

  def handle_call({:weather, location}, _from, stats) do
    {:reply, temperature_for(location), update_stats(stats, location)}
  end

  def handle_cast(:stop, stats) do
    {:stop, :normal, stats}
  end

  def handle_cast(:reset_stats, _stats) do
    {:noreply, %{}}
  end

  def init(_) do
    {:ok, %{}}
  end

  def terminate(reason, stats) do
    case reason do
      :normal ->
        IO.puts stats
        :ok

      _ ->
        IO.puts "Server terminated. Reason unknown."
        ok
    end
  end

  ## Helper Functions ##

  defp api_key do
    System.get_env("OPENWEATHER_API_TOKEN")
  end

  defp parse_json({:ok, json}) do
    temp = (json["main"]["temp"] - 273.15) |> Float.round(1)
    {:ok, temp}
  end

  defp parse_json(_) do
    :error
  end

  defp parse_response({:ok, %HTTPoison.Response{status_code: 200, body: body}}) do
    body |> Poison.decode
  end

  defp temperature_for(location) do
    result = location |> url_for |> HTTPoison.get |> parse_response |> parse_json

    case result do
      {:ok, temp} -> "#{location}: #{temp}C"
      :error -> "Unknown location"
    end
  end

  defp update_stats(stats, location) do
    case Map.has_key?(stats, location) do
      true -> %{stats | location => (stats[location] + 1)}
      false -> Map.put(stats, location, 1)
    end
  end

  defp url_for(location) do
    "http://api.openweathermap.org/data/2.5/weather?q=#{URI.encode(location)}&appid=#{api_key}"
  end
end
