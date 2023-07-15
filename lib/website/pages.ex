defmodule Website.Pages do
  use Phoenix.Component
  import Phoenix.HTML
  import Website.Components

  embed_templates "pages/*"
end
