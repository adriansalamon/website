defmodule Website.Image do
  use Phoenix.Component

  @static_path "./priv"
  @output_path "./output/assets/static"
  @breakpoints [16, 32, 48, 64, 96, 128, 256, 384, 640, 750, 828, 1080, 1200, 1920]

  attr :src, :string, required: true
  attr :sizes, :string, default: ""
  attr :rest, :global

  def image(assigns) do
    if String.starts_with?(assigns.src, "/") do
      static_image(assigns)
    else
      external_image(assigns)
    end
  end

  defp external_image(assigns) do
    ~H"""
    <img src={@src} {@rest} />
    """
  end

  defp static_image(assigns) do
    src = assigns.src
    path = Path.join(@static_path, src)

    if File.exists?(path) do
      image = Image.open!(path)

      paths =
        for breakpoint <- @breakpoints do
          file = Path.split(path) |> List.last() |> String.split(".") |> hd()
          out_path = Path.join(@output_path, "#{file}-#{breakpoint}.jpg")

          if !File.exists?(out_path) do
            File.mkdir_p!(Path.dirname(out_path))

            Image.thumbnail!(image, breakpoint)
            |> Image.write!(out_path)
          end

          %{path: String.trim_leading(out_path, "./output"), w: breakpoint}
        end

      srcset =
        Enum.map(paths, fn path ->
          "#{path.path} #{path.w}w"
        end)
        |> Enum.join(", ")

      assigns =
        assigns
        |> assign(:largest, hd(paths).path)
        |> assign(:srcset, srcset)

      ~H"""
      <img src={@largest} srcset={@srcset} {@rest} />
      """
    else
      external_image(assigns)
    end
  end
end
