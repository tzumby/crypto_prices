defmodule CryptoPrices.Aggregator.Poloniex do
  @limit 10
  @base "https://poloniex.com/public?command=returnOrderBook"

  def compute(pair, _opts) do
    pair
    |> convert_pair()
    |> fetch_json() 
    |> format_results()
  end

  defp format_results({:ok, %{ "asks" => asks }}) do
    asks
    |> Enum.map(&build_bid/1)
  end

  defp build_bid([price, quantity ]) do 
    {price, _} = Float.parse(price)
    %{price: price, quantity: quantity}
  end

  defp convert_pair(pair) do
    case pair do
      "BTC-ETH" -> "BTC_ETH"
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
    "#{@base}&" <> URI.encode_query(currencyPair: pair, depth: @limit)
  end
end
