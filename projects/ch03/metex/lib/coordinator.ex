defmodule Metex.Coordinator do
  def loop(results \\ [], results_expected) do
    receive do
      {:ok, result} ->
        results = [result | results]

        if results_expected == Enum.count(results) do
          send self, :exit
        end

        loop(results, results_expected)

      :exit ->
        IO.puts(Enum.join(results, ", "))

      _ -> loop(results, results_expected)
    end
  end
end
