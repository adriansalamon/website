defmodule Website.Build.Posts.Post do
  @enforce_keys [:id, :author, :title, :body, :description, :tags, :date, :path, :url]
  defstruct [:id, :author, :title, :body, :description, :tags, :date, :path, :url]

  @base_dir "priv/"

  def build(filename, attrs, body) do
    path = Path.rootname(filename) |> String.trim_leading(@base_dir)

    [year, month_day_id] = path |> Path.split() |> Enum.take(-2)
    file_path = Path.join(path, "index.html")

    [month, day, id] = String.split(month_day_id, "-", parts: 3)

    date = Date.from_iso8601!("#{year}-#{month}-#{day}")

    struct!(
      __MODULE__,
      [id: id, date: date, body: body, path: "/" <> file_path, url: "/" <> path] ++
        Map.to_list(attrs)
    )
  end
end

defmodule Website.Build.Posts do
  use NimblePublisher,
    build: __MODULE__.Post,
    from: "priv/posts/**/*.md",
    as: :posts,
    highlighters: [:makeup_elixir],
    html_converter: Website.Build.HTMLConverter

  @posts Enum.sort_by(@posts, & &1.date, {:desc, Date})

  def all_posts, do: @posts
end
