defmodule Website.MixProject do
  use Mix.Project

  def project do
    [
      app: :website,
      version: "0.1.0",
      elixir: "~> 1.13",
      start_permanent: Mix.env() == :prod,
      aliases: aliases(),
      deps: deps()
    ]
  end

  defp aliases() do
    [
      "site.build": ["build", "tailwind default --minify", "esbuild default --minify"],
      "site.serve": ["server"]
    ]
  end

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      mod: {Website.Application, []},
      extra_applications: [:logger]
    ]
  end

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      {:nimble_publisher, "~> 1.1"},
      {:makeup_elixir, ">= 0.0.0"},
      {:makeup_erlang, ">= 0.0.0"},
      {:md, "~> 0.12"},
      {:phoenix_live_view, "~> 1.1"},
      {:heroicons, "~> 0.5.1"},
      {:image, "~> 0.66.0"},
      {:phoenix_seo, "~> 0.2.1"},
      {:jason, "~> 1.0"},
      {:tailwind, "~> 0.2", runtime: Mix.env() == :dev},
      {:esbuild, "~> 0.7", runtime: Mix.env() == :dev},
      {:bandit, "~> 1.10", only: :dev},
      {:file_system, "~> 1.1", only: :dev},
      {:tailwind_formatter, "~> 0.4.2", only: [:dev], runtime: false}
    ]
  end
end
