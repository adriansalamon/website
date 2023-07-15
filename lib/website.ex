defmodule Website do
  use Phoenix.Component
  import Website.Pages

  @output_dir "./output"

  def build() do
    File.mkdir_p!(@output_dir)
    posts = Website.Blog.all_posts()

    projects = [
      %{name: "Haj", description: "A platform for METAspexet written in Elixir."},
      %{
        name: "ClockClock24 Replica",
        description: "A digital clock consisting of 24 analog clocks."
      },
      %{
        name: "RLTCol",
        description: "Reinforcement learning for solving the Graph Coloring Problem"
      }
    ]

    render_file("index.html", index(%{posts: posts, projects: projects}))
    render_file("blog/index.html", blog(%{posts: posts}))
    render_file("projects/index.html", projects(%{}))
    render_file("about/index.html", about(%{}))

    for post <- posts do
      dir = Path.dirname(post.path)

      if dir != "." do
        File.mkdir_p!(Path.join([@output_dir, dir]))
      end

      render_file(post.path, post(%{post: post}))
    end

    :ok
  end

  def render_file(path, rendered) do
    dir = Path.dirname(path)
    File.mkdir_p!(Path.join([@output_dir, dir]))

    safe = Phoenix.HTML.Safe.to_iodata(rendered)
    output = Path.join([@output_dir, path])
    File.write!(output, safe)
  end
end
