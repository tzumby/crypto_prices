defmodule CryptoPrices.Aggregator.Supervisor do
  alias CryptoPrices.Aggregator

  use Supervisor

  def start_link(opts) do
    Supervisor.start_link(__MODULE__, opts, name: __MODULE__)
  end

  def init(opts) do
    children = [
      {Task.Supervisor, name: Aggregator.TaskSupervisor}
    ]

    Supervisor.init(children, strategy: :rest_for_one)
  end
end
