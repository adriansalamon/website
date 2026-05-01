# Used by "mix format"
[
  inputs: ["{mix,.formatter}.exs", "{config,lib,test}/**/*.{ex,exs,heex}"],
  plugins: [TailwindFormatter, Phoenix.LiveView.HTMLFormatter],
  import_deps: [
    :plug,
    :phoenix
  ]
]
