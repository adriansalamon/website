defmodule Website.Blog do
  alias Website.Post

  use NimblePublisher,
    build: Post,
    from: "./priv/posts/**/*.md",
    as: :posts,
    highlighters: [:makeup_elixir]

  @posts Enum.sort_by(@posts, & &1.date, {:desc, Date})

  def all_posts, do: @posts
end
