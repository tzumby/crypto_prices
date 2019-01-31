defmodule CryptoPrices.Aggregator.Kraken do
  @limit 10
  @base "https://api.kraken.com/0/public/Depth"

  def compute(pair, _opts) do
    pair
    |> convert_pair()
    |> fetch_json() 
    |> format_results(pair)
  end

  defp format_results({:ok, %{ "result" => result }}, pair) do
    result[convert_pair(pair)]["asks"]
    |> Enum.map(&build_bid/1)
  end

  defp build_bid([price, quantity, _timestamp ]) do 
    {price, _} = Float.parse(price)
    {quantity, _} = Float.parse(quantity)
    %{price: price, quantity: quantity}
  end

  defp convert_pair(pair) do
    case pair do
      "BTC-ETH" -> "XETHXXBT"
    end
  end

  defp fetch_json(pair) do
    case HTTPoison.get(url(pair)) do
      {:ok, %HTTPoison.Response{body: body, status_code: 200}} ->
        {:ok, Jason.decode!(body) }
      {:ok, %HTTPoison.Response{status_code: 404}} ->
        {:error, :not_found }
      {:ok, %HTTPoison.Error{reason: reason}} ->
        {:error, reason } 
    end
  end

  defp url(pair) do
    "#{@base}?" <> URI.encode_query(pair: pair, count: @limit)
  end
end
