defmodule Website.Build.HTMLConverter do
  def convert(extname, content, _attrs, _opts) when extname in [".md"] do
    Md.generate(content, format: :none)
  end
end
