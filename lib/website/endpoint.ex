defmodule Website.Endpoint do
  use Plug.Builder

  if Mix.env() == :dev do
    plug Website.LiveReload.Plug
    plug Plug.Static.IndexHtml
    plug Plug.Static, at: "/", from: "output", only: ~w(assets)
    plug Website.LiveReload.StaticHTML, at: "/", from: "output"
    plug Website.LiveReload.SocketRouter
  end
end
