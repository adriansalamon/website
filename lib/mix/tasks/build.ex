defmodule Mix.Tasks.Build do
  use Mix.Task

  require Logger

  @impl Mix.Task
  def run(_args) do
    Mix.Task.run("app.start", ["--preload-modules"])

    mods = :code.all_available()

    for {mod, _, _} <- mods do
      Module.concat([to_string(mod)]) |> dbg()
    end

    {micro, :ok} =
      :timer.tc(fn ->
        Website.build()
      end)

    ms = micro / 1000
    IO.puts("Built in #{ms}ms ⚡️")
  end
end
