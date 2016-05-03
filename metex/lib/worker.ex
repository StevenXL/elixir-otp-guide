defmodule Metex.Worker do
  def loop do
    receive do
      {sender_pid, location} ->
        send(sender_pid, {:ok, temperature_for(location)})
      _ ->
        nil
    end
  end

  def temperature_for(location) when is_binary(location) do
    result = location |> url_for |> HTTPoison.get |> parse_response |> retrieve_temp

    case result do
      {:ok, temp} ->
        "#{location}: #{temp}C"
      :error ->
        "Unknown location"
    end
  end

  def url_for(location) do
    "http://api.openweathermap.org/data/2.5/weather?q=#{URI.encode(location)}&appid=#{api_key}"
  end

  defp api_key do
    System.get_env("OPENWEATHER_API_TOKEN")
  end

  defp parse_response(response) do
    case response do
      {:ok, %HTTPoison.Response{status_code: 200, body: body}} ->
        {:ok, json} = Poison.decode(body)
      _ ->
        :error
    end
  end

  defp retrieve_temp({:ok, json}) do
    temp = (json["main"]["temp"] - 273.15) |> Float.round(1)
    {:ok, temp}
  end

  defp retrieve_temp(_) do
    :error
  end
end
