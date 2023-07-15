defmodule Website.LiveReload.SocketRouter do
  use Plug.Router

  plug :match
  plug :dispatch

  get "/live_reload/socket" do
    conn
    |> WebSockAdapter.upgrade(Website.LiveReload.Socket, [], timeout: 60_000)
    |> halt()
  end
end
