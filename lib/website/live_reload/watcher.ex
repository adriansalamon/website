defmodule Website.LiveReload.Watcher do
  use GenServer

  def start_link(args) do
    GenServer.start_link(__MODULE__, args)
  end

  def init(args) do
    FileSystem.start_link(args)
  end
end
