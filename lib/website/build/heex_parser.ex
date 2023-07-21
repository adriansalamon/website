defmodule Website.Build.HEEXParser do
  require Phoenix.LiveView.TagEngine
  alias Phoenix.HTML.Safe.Phoenix.LiveView
  alias Md.Parser.State

  import Phoenix.Component

  @behaviour Md.Parser

  @impl true
  def parse(input, state \\ %State{})

  def parse(input, state) do
    [top_tag, rest] =
      String.split(input, ">", parts: 2)

    [tag, attrs, content, rest] =
      case String.ends_with?(top_tag, "/") do
        true ->
          [tag, attrs] =
            String.trim_trailing(top_tag, "/")
            |> String.split(" ", parts: 2)

          [tag, attrs, "", rest]

        false ->
          [tag, attrs] = String.split(top_tag, " ", parts: 2)
          [content, rest] = String.split(rest, "</.#{tag}>", parts: 2)
          [tag, attrs, content, rest]
      end
      |> dbg()

    quoted =
      Md.Parser.generate(content)
      |> EEx.compile_string(engine: Phoenix.LiveView.Engine)

    {result, _bindings} = Code.eval_quoted(quoted, assigns: %{})

    assigns =
      attrs
      |> String.trim()
      |> String.split(~r|\s+|)
      |> Enum.reject(&(&1 == ""))
      |> Enum.reduce(
        %{
          __changed__: %{},
          inner_block: %{__slot__: :inner_block, inner_block: fn _, _ -> result end}
        },
        fn attr, acc ->
          [key, value] = String.split(attr, "=", parts: 2)
          value = String.trim(value, "\"")

          Map.put(acc, String.to_atom(key), value)
        end
      )

    rendered = apply(Website.Components, String.to_atom(tag), [assigns])

    rendered_html =
      Phoenix.HTML.Safe.to_iodata(rendered)
      |> IO.chardata_to_string()

    {rest, %State{state | ast: [rendered_html | state.ast]}}
  end
end
