defmodule Website do
  use Phoenix.Component
  import Website.Pages
  import Website.Build.Render

  alias Website.Build.Posts
  alias Website.Build.Projects

  @output_dir Application.compile_env(:website, :output_dir, "output")
  @content_dir Application.compile_env(:website, :content_dir, "priv/")
  @static_dir Application.compile_env(:website, :static_dir, "priv/static")

  defp fingerprint_css do
    src = Path.join(@output_dir, "assets/app.css")
    content = File.read!(src)
    hash = :crypto.hash(:sha256, content) |> Base.encode16(case: :lower) |> binary_part(0, 8)
    hashed = "app-#{hash}.css"
    File.rename!(src, Path.join(@output_dir, "assets/#{hashed}"))
    "/assets/#{hashed}"
  end

  defp find_js do
    case Path.wildcard(Path.join(@output_dir, "assets/app-*.js")) do
      [path | _] -> "/assets/" <> Path.basename(path)
      [] -> "/assets/app.js"
    end
  end

  def build() do
    if Mix.env() == :prod do
      Application.put_env(:website, :asset_css, fingerprint_css())
      Application.put_env(:website, :asset_js, find_js())
    end

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
      conn = SEO.assign(%Plug.Conn{}, post)
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

    if File.exists?(@static_dir) do
      static_files = File.ls!(@static_dir)

      for file <- static_files do
        File.cp_r!(Path.join([@static_dir, file]), Path.join([@output_dir, file]))
      end
    end

    :ok
  end
end
