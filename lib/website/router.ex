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
    Website.LiveReload.CodeReloader.reload()
    conn
  end

  defp rerender(conn, _) do
    headers = get_req_header(conn, "accept")

    if Enum.any?(headers, &String.contains?(&1, "text/html")) do
      Mix.Task.rerun("build")
    end

    conn
  end
end
