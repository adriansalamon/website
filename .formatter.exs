# Used by "mix format"
[
  inputs: ["{mix,.formatter}.exs", "{config,lib,test}/**/*.{ex,exs}"],
  plugins: [Phoenix.LiveView.HTMLFormatter, TailwindFormatter],
  import_deps: [
    :plug,
    :phoenix
  ]
]
