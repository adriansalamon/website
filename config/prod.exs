import Config

config :website,
  scheme: "https",
  hostname: "asalamon.se",
  port: 443

config :esbuild,
  default: [
    args: ~w(js/app.js --bundle --target=es2016 --entry-names=[dir]/[name]-[hash] --outdir=../_site/assets),
    cd: Path.expand("../assets", __DIR__),
    env: %{"NODE_PATH" => Path.expand("../deps", __DIR__)}
  ]
