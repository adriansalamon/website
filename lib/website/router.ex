defmodule Website.Router do
  use Plug.Router, init_mode: :runtime

  plug :recompile
  plug :rerender

  plug Website.LiveReload.IndexHtml
  plug Plug.Static, at: "/", from: "output", cache_control_for_etags: "no-cache"

  plug :match
  plug :dispatch

  get "/live_reload/socket" do
    conn
    |> WebSockAdapter.upgrade(Website.LiveReload.Socket, [], timeout: 60_000)
    |> halt()
  end

  defp recompile(conn, _) do
    conn
  end

  defp rerender(conn, _) do
    Mix.Task.rerun("site.build")

    conn
  end
end
