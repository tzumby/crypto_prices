defmodule CryptoPrices do
  alias CryptoPrices.Aggregator

  @clients [Aggregator.Bittrex, Aggregator.Poloniex, Aggregator.Kraken]

  def compute(pair, opts \\ []) do
    timeout = opts[:timeout] || 5_000
    opts = Keyword.put_new(opts, :limit, 10)
    clients = opts[:clients] || @clients

    clients
    |> Enum.map(&async_query(&1, pair, opts))
    |> Task.yield_many(timeout)
    |> Enum.map(fn {task, res} -> res || Task.shutdown(task, :brutal_kill) end)
    |> Enum.flat_map(fn
      {:ok, results } -> results
      _ -> []
    end)
    |> Enum.reduce({0,0}, &avg/2)
    |> avg_finalize
  end


  # Enum.reduce([1, 2, 3], 0, fn x, acc -> x + acc end)
  defp avg(x, {sum, count}), do: {sum + x.price, count + 1}
  defp avg_finalize({sum, count}), do: sum / count

  defp async_query(client, pair, opts) do
    Task.Supervisor.async_nolink(Aggregator.TaskSupervisor,
      client, :compute, [pair, opts], shutdown: :brutal_kill
    )
  end
end
