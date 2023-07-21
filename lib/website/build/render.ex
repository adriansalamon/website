defmodule Website.Build.Render do
  @output_dir "output"

  def render_file(path, rendered) do
    dir = Path.dirname(path)
    File.mkdir_p!(Path.join([@output_dir, dir]))

    safe = Phoenix.HTML.Safe.to_iodata(rendered)
    output = Path.join([@output_dir, path])
    File.write!(output, safe)
  end
end
