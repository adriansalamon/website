defmodule Website do
  use Phoenix.Component
  import Website.Pages
  import Website.Build.Render

  alias Website.Build.Posts
  alias Website.Build.Projects

  @output_dir Application.compile_env(:website, :output_dir, "output")
  @content_dir Application.compile_env(:website, :content_dir, "priv/")

  def build() do
    posts = Posts.all_posts()
    projects = Projects.all_projects()

    render_file(
      "index.html",
      index(%{posts: posts, projects: Projects.featured_projects()})
    )

    render_file("blog/index.html", blog(%{posts: posts}))
    render_file("projects/index.html", projects(%{projects: projects}))
    render_file("about/index.html", about(%{}))

    for post <- posts do
      conn = SEO.assign(Phoenix.ConnTest.build_conn(), post)
      render_file(post.path, post(%{post: post, conn: conn}))
    end

    for project <- projects do
      render_file(project.path, project(%{project: project}))
    end

    asset_path = Path.join(@content_dir, "assets")
    asset_files = File.ls!(asset_path)

    for file <- asset_files do
      File.cp_r!(Path.join([asset_path, file]), Path.join([@output_dir, "assets", file]))
    end

    :ok
  end
end
