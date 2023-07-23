defmodule Website.Build.HTMLConverter do
  def convert(extname, content, _attrs, opts) when extname in [".md"] do
    highlighters = Keyword.get(opts, :highlighters, [])

    Md.generate(content, format: :none) |> NimblePublisher.highlight(highlighters)
  end
end
