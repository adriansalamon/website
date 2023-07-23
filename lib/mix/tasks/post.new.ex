defmodule Mix.Tasks.Post.New do
  require Logger

  @content_dir Application.compile_env(:website, :content_dir, "priv/")

  use Mix.Task

  def run([name]) do
    date = DateTime.utc_now() |> DateTime.to_date()

    month_day = Date.to_iso8601(date) |> String.slice(5..-1)

    filename = "#{month_day}-#{name}.md"

    path = Path.join([@content_dir, "posts", "#{date.year}", filename])
    File.mkdir_p!(Path.dirname(path))

    if File.exists?(path) do
      if Mix.shell().yes?("File #{filename} already exists, overwrite?", default: :no) do
        write_file(path)
      end
    else
      write_file(path)
    end
  end

  def run(_), do: Mix.raise("mix new.post expects a name")

  defp write_file(path) do
    File.write!(path, """
    %{
      title: "",
      author: "Adrian Salamon",
      description: "",
      tags: ~w()
    }
    ---
    """)

    Mix.shell().info("Created #{path}")
  end
end
