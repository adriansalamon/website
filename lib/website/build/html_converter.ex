defmodule Website.Build.HTMLConverter do
  def convert(_path, content, _attrs, _opts) do
    Md.generate(content, format: :none)
    |> NimblePublisher.highlight(regex: ~r/<pre><code(?:\s+class="(\w*).*")?>([^<]*)<\/code><\/pre>/)
  end
end
