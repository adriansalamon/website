defmodule Website.Build.Posts.Post do
  @enforce_keys [
    :id,
    :author,
    :title,
    :body,
    :description,
    :reading_time,
    :tags,
    :date,
    :path,
    :url
  ]
  defstruct [:id, :author, :title, :body, :description, :reading_time, :tags, :date, :path, :url]

  @content_dir Application.compile_env(:website, :content_dir, "priv/")

  def build(filename, attrs, body) do
    path = Path.rootname(filename) |> String.trim_leading(@content_dir)

    [year, month_day_id] = path |> Path.split() |> Enum.take(-2)
    file_path = Path.join(path, "index.html")

    [month, day, id] = String.split(month_day_id, "-", parts: 3)

    date = Date.from_iso8601!("#{year}-#{month}-#{day}")
    reading_time = reading_time(body)

    struct!(
      __MODULE__,
      [
        id: id,
        date: date,
        body: body,
        reading_time: reading_time,
        path: "/" <> file_path,
        url: "/" <> path
      ] ++
        Map.to_list(attrs)
    )
  end

  defp reading_time(body) do
    words_per_minute = 200

    words =
      String.replace(body, ~r{<[^>]*>}, " ")
      |> String.split(~r{\s+}, trim: true)
      |> length()

    Float.ceil(words / words_per_minute)
    |> trunc()
  end
end

defmodule Website.Build.Posts do
  @content_dir Application.compile_env(:website, :content_dir, "priv/")

  use NimblePublisher,
    build: __MODULE__.Post,
    from: "#{@content_dir}/posts/**/*.md",
    as: :posts,
    highlighters: [:makeup_elixir],
    html_converter: Website.Build.HTMLConverter

  @posts Enum.sort_by(@posts, & &1.date, {:desc, Date})

  def all_posts, do: @posts
end
