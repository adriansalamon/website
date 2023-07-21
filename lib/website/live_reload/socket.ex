defmodule Website.LiveReload.Socket do
  require Logger
  @behaviour WebSock

  def init(_args) do
    :ok = Website.LiveReload.Reloader.init(name: :live_reload_watcher)
    {:ok, []}
  end

  def handle_in(_in, state) do
    {:ok, state}
  end

  def handle_info({:reload, _asset_type}, state) do
    {:push, {:text, "reload"}, state}
  end

  def handle_info({:file_event, _pid, {_path, events}} = file_event, state) do
    if :modified in events do
      Website.LiveReload.Reloader.reload!(file_event,
        patterns: Application.get_env(:website, :live_reload_patterns, [])
      )
    end

    {:ok, state}
  end

  def handle_info(message, state) do
    Logger.warning("Unhandled message: #{inspect(message)}")
    {:ok, state}
  end
end
