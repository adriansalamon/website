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
      "site.build": ["build", "tailwind default --minify", "esbuild default --minify"]
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
      {:nimble_publisher, git: "https://github.com/dashbitco/nimble_publisher"},
      {:makeup_elixir, ">= 0.0.0"},
      {:makeup_erlang, ">= 0.0.0"},
      {:md, git: "https://github.com/adriansalamon/md", branch: "block-escape-html"},
      {:phoenix_live_view, "~> 0.19"},
      {:heroicons, "~> 0.5.1"},
      {:image, "~> 0.36.0"},
      {:phoenix_seo, "~> 0.1.8"},
      {:jason, "~> 1.0"},
      {:tailwind, "~> 0.2", runtime: Mix.env() == :dev},
      {:esbuild, "~> 0.7", runtime: Mix.env() == :dev},
      {:bandit, "~> 1.0-pre", only: :dev},
      {:file_system, "~> 0.2", only: :dev},
      {:tailwind_formatter, "~> 0.3.6", only: [:dev], runtime: false}
    ]
  end
end
