defmodule Website.Build.Projects.Project do
  @enforce_keys [:name, :body, :tags, :description, :path, :link, :url]
  defstruct [:name, :body, :tags, :description, :path, :link, :url]

  @base_dir "priv/"

  def build(filename, attrs, body) do
    url =
      Path.rootname(filename)
      |> String.trim_leading(@base_dir)

    path = Path.join(url, "index.html")

    struct!(__MODULE__, [body: body, path: "/" <> path, url: "/" <> url] ++ Map.to_list(attrs))
  end
end

defmodule Website.Build.Projects do
  use NimblePublisher,
    build: __MODULE__.Project,
    from: "priv/projects/**/*.md",
    as: :projects,
    html_converter: Website.Build.HTMLConverter

  def all_projects, do: @projects

  def featured_projects, do: Enum.filter(@projects, &("featured" in &1.tags))
end
