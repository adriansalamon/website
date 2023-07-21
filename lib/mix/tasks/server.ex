defmodule Mix.Tasks.Server do
  use Mix.Task

  require Logger

  @impl Mix.Task
  def run(_args) do
    Logger.debug("Starting server...")

    Mix.Task.run("app.start", ["--preload-modules"])

    Mix.Tasks.Run.run(["--no-halt"])
  end
end
