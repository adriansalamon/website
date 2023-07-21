defmodule Mix.Tasks.Build do
  use Mix.Task

  require Logger

  @impl Mix.Task
  def run(_args) do
    Mix.Task.run("app.start", ["--preload-modules"])

    {micro, :ok} =
      :timer.tc(fn ->
        Website.build()
      end)

    ms = micro / 1000
    Logger.debug("Built site in #{ms}ms ⚡️")
  end
end
