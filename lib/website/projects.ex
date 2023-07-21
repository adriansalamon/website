defmodule Website.Projects do
  alias Website.Project

  use NimblePublisher,
    build: Project,
    from: "./priv/projects/**/*.md",
    as: :projects,
    html_converter: Website.HTMLConverter

  def all_projects, do: @projects

  def featured_projects, do: Enum.filter(@projects, &("featured" in &1.tags))
end
