defmodule CryptoPrices.Aggregator.Bittrex do
  @limit 10
  @base "http://api.bittrex.com/api/v1.1/public/getorderbook"

  def compute(pair, _opts) do
    pair
    |> fetch_json() 
    |> format_results()
  end

  defp format_results({:ok, %{ "result" => %{ "sell" => sell  }}}) do
    sell
    |> Enum.map(&build_bid/1)
    |> Enum.take(@limit)
  end

  defp build_bid(%{ "Quantity" => quantity, "Rate" => price }) do 
    %{price: price, quantity: quantity}
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
    "#{@base}?" <> URI.encode_query(market: pair, type: "both")
  end
end
