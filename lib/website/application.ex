defmodule Website.Application do
  def start(_type, _args) do
    children = [
      {Bandit, plug: Website.Router},
      Website.LiveReload.Watcher,
      Website.LiveReload.CodeReloader
    ]

    opts = [strategy: :one_for_one, name: Website.Supervisor]
    Supervisor.start_link(children ++ asset_children(), opts)
  end

  defp asset_children() do
    for conf <- Application.get_env(:website, :assets, []) do
      {Website.LiveReload.Assets, conf}
    end
  end
end
