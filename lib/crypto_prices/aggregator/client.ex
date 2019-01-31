defmodule CryptoPrices.Aggregator.Client do
  @callback name() :: String.t
  @callback compute(pair :: String.t(), opts :: Keyword.t()) :: [result :: map() ]
end
