defmodule Website.LiveReload.Socket do
  require Logger
  @behaviour WebSock

  def init(_args) do
    if Process.whereis(:live_reload_watcher) do
      FileSystem.subscribe(:live_reload_watcher)
      {:ok, []}
    else
      Logger.warning("live reload process not running")
      {:stop, []}
    end
  end

  def handle_in(_in, state) do
    {:ok, state}
  end

  def handle_info({:file_event, _pid, {_path, events}}, state) do
    if :modified in events do
      System.cmd("mix", ["site.build"], into: IO.stream())

      {:push, {:text, "reload"}, state}
    else
      {:ok, state}
    end
  end

  def handle_info({:file_event, watcher_pid, :stop}, %{watcher_pid: watcher_pid} = state) do
    {:ok, state}
  end
end
