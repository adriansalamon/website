import Config

config :esbuild,
  version: "0.18.6",
  default: [
    args: ~w(js/app.js --bundle --target=es2016 --outdir=../output/assets),
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
         --output=../output/assets/app.css
       )
  ]
