defmodule Website.HTMLConverter do
  alias Phoenix.Template

  def convert(extname, content, _attrs, _opts) when extname in [".md"] do
    Md.generate(content)
  end
end
