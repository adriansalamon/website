defmodule Website.Application do
  def start(_type, _args) do
    children = [
      {Bandit, plug: Website.Router},
      {Website.LiveReload.Watcher, dirs: ["lib/", "assets/*"], name: :live_reload_watcher}
    ]

    opts = [strategy: :one_for_one, name: Website.Supervisor]
    Supervisor.start_link(children, opts)
  end
end
