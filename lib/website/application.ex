defmodule Website.Application do
  use Application

  def start(_type, _args) do
    children = [Website.Application.Supervisor]

    opts = [strategy: :one_for_one, name: Website.Supervisor]
    Supervisor.start_link(children, opts)
  end
end

defmodule Website.Application.Supervisor do
  use Supervisor

  def start_link(args) do
    Supervisor.start_link(__MODULE__, args, name: __MODULE__)
  end

  def init(_args) do
    children = [
      {Bandit, plug: Website.Router},
      Website.LiveReload.Watcher,
      Website.LiveReload.CodeReloader
    ]

    if Mix.env() == :dev do
      Supervisor.init(children ++ asset_children(), strategy: :one_for_one)
    else
      :ignore
    end
  end

  defp asset_children() do
    for conf <- Application.get_env(:website, :assets, []) do
      {Website.LiveReload.Assets, conf}
    end
  end
end
