import Config

output_dir = "_site"

config :esbuild,
  version: "0.18.6",
  default: [
    args: ~w(js/app.js --bundle --target=es2016 --outdir=../#{output_dir}/assets),
    cd: Path.expand("../assets", __DIR__),
    env: %{"NODE_PATH" => Path.expand("../deps", __DIR__)}
  ]

config :tailwind,
  version: "3.2.4",
  default: [
    cd: Path.expand("../assets", __DIR__),
    args: ~w(
         --config=tailwind.config.js
         --input=css/app.css
         --output=../#{output_dir}/assets/app.css
       )
  ]

config :md,
  syntax: %{
    custom: [{"<.", {Website.Build.HEEXParser, %{}}}]
  }

config :website,
  live_reload_patterns: [
    ~r"lib/website/.*.(he)?ex",
    ~r"priv/(posts|projects)/.*.md",
    ~r"assets/.*.(js|css)"
  ],
  assets: [
    esbuild: {Esbuild, :install_and_run, [:default, ~w(--sourcemap=inline --watch)]},
    tailwind: {Tailwind, :install_and_run, [:default, ~w(--watch)]}
  ],
  output_dir: output_dir,
  content_dir: "priv/"

import_config "#{config_env()}.exs"
