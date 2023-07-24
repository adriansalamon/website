defmodule Website.Images do
  @content_dir Application.compile_env(:website, :content_dir, "priv/")
  @output_dir Application.compile_env(:website, :output_dir, "output")
  @output_path "#{@output_dir}/assets/static"
  @breakpoints [16, 32, 48, 64, 96, 128, 256, 384, 640, 750, 828, 1080, 1200, 1920]

  def file_exists?(path) do
    path = Path.join(@content_dir, path)
    File.exists?(path)
  end

  def generate_variants(path, options \\ []) do
    breakpoints = Keyword.get(options, :breakpoints, @breakpoints)
    format = Keyword.get(options, :format, "webp")

    path = Path.join(@content_dir, path)
    image = Image.open!(path)

    for breakpoint <- breakpoints do
      file_name = Path.split(path) |> List.last() |> String.split(".") |> hd()
      out_path = Path.join(@output_path, "#{file_name}-#{breakpoint}.#{format}")

      if !File.exists?(out_path) do
        File.mkdir_p!(Path.dirname(out_path))

        Image.thumbnail!(image, breakpoint)
        |> Image.write!(out_path)
      end

      %{path: String.trim_leading(out_path, @output_dir), w: breakpoint}
    end
  end

  @svg """
  <?xml version="1.0" encoding="UTF-8" standalone="no"?>
  <svg
   width="1200"
   height="630"
   viewBox="0 0 317.50001 166.6875"
   version="1.1"
   id="svg5"
   xml:space="preserve"
   xmlns="http://www.w3.org/2000/svg"
   xmlns:svg="http://www.w3.org/2000/svg"><defs
     id="defs2"><rect
       x="65.335536"
       y="446.04068"
       width="631.99566"
       height="84.182325"
       id="rect1078" /><rect
       x="47.745199"
       y="84.182325"
       width="1047.8851"
       height="419.45103"
       id="rect914" /><clipPath
       clipPathUnits="userSpaceOnUse"
       id="clipPath1165"><ellipse
         style="fill:#000000;stroke:#000000;stroke-width:0.160434;paint-order:stroke fill markers;stop-color:#000000"
         id="ellipse1167"
         cx="25.300297"
         cy="132.4238"
         rx="12.830408"
         ry="13.201157" /></clipPath><rect
       x="65.335533"
       y="446.04068"
       width="631.99567"
       height="84.182327"
       id="rect1078-5" /></defs><g
     id="layer1"><text
       xml:space="preserve"
       transform="matrix(0.26458333,0,0,0.26458333,0.33243642,-0.49706412)"
       id="text912"
       style="font-style:normal;font-variant:normal;font-weight:bold;font-stretch:normal;font-size:78px;font-family:Inter;letter-spacing:0px;white-space:pre;shape-inside:url(#rect914);display:inline;fill:#1a1a1a;stroke:#000000;stroke-width:0.755906;paint-order:stroke fill markers;stop-color:#000000"><tspan
         x="47.746094"
         y="157.524"
         id="tspan1887"><tspan
           style="font-family:Inter;"
           id="tspan1885">LINE_1
  </tspan></tspan><tspan
         x="47.746094"
         y="257.2046"
         id="tspan1891"><tspan
           style="font-family:Inter;"
           id="tspan1889">LINE_2
  </tspan></tspan><tspan
         x="47.746094"
         y="356.8852"
         id="tspan1895"><tspan
           style="font-family:Inter;"
           id="tspan1893">LINE_3
  </tspan></tspan><tspan
         x="47.746094"
         y="456.56581"
         id="tspan1899"><tspan
           style="font-family:Inter;"
           id="tspan1897">LINE_4</tspan></tspan></text><text
       xml:space="preserve"
       transform="matrix(0.26458333,0,0,0.26458333,23.468821,21.082195)"
       id="text1076"
       style="font-style:normal;font-variant:normal;font-weight:normal;font-stretch:normal;font-size:40px;font-family:hel;letter-spacing:0px;white-space:pre;shape-inside:url(#rect1078);display:inline;fill:#1a1a1a;stroke:#000000;stroke-width:0.755906;paint-order:stroke fill markers;stop-color:#000000"><tspan
         x="65.335938"
         y="483.65248"
         id="tspan1903"><tspan
           style="font-family:Inter;"
           id="tspan1901">Adrian Salamon</tspan></tspan></text></g></svg>
  """

  @max_length 28
  @tags ~w(LINE_1 LINE_2 LINE_3 LINE_4)

  def generate_og_image(post) do
    output_path = Path.join(@output_dir, ["assets/static/og-images/", post.id, ".jpg"])
    File.mkdir_p!(Path.dirname(output_path))

    text_overlay =
      String.split(post.title, " ")
      |> Enum.reduce([], &wrap_words/2)
      |> Enum.reverse()
      |> replace_headings()
      |> Image.from_svg!()

    base_image = Image.open!(Path.join(@content_dir, "assets/static/og-background.png"))

    avatar_image =
      Image.open!(Path.join(@content_dir, "assets/static/profile.jpeg"))
      |> Image.avatar!(size: 65)

    Image.compose!(base_image, avatar_image, x: 58, y: 516)
    |> Image.compose!(text_overlay)
    |> Image.write!(output_path)

    String.trim_leading(output_path, @output_dir)
  end

  defp wrap_words(word, [curr | rest] = acc) do
    concatinated = curr <> " " <> word

    if String.length(concatinated) > @max_length do
      [word | acc]
    else
      [concatinated | rest]
    end
  end

  defp wrap_words(word, []) do
    [word]
  end

  defp replace_headings(headings) do
    {svg, _} =
      Enum.reduce(@tags, {@svg, headings}, fn tag, {svg, headings} ->
        case headings do
          [] -> {String.replace(svg, tag, ""), []}
          [head | rest] -> {String.replace(svg, tag, head), rest}
        end
      end)

    svg
  end
end
