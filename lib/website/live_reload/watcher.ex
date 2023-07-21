defmodule Website.LiveReload.Watcher do
  def child_spec(_) do
    file_system_opts =
      Keyword.merge([dirs: [Path.absname("")]], name: :live_reload_watcher, latency: 0)

    %{
      id: FileSystem,
      start: {FileSystem, :start_link, [file_system_opts]}
    }
  end
end
