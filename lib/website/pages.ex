defmodule Website.Pages do
  use Phoenix.Component
  import Phoenix.HTML
  import Website.Components
  import Website.Image

  embed_templates "pages/*"
end
