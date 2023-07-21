defmodule Website.Build.HEEXParser do
  alias Md.Parser.State

  @behaviour Md.Parser

  @impl true
  def parse(input, state \\ %State{})

  def parse(input, state) do
    [tag, rest] = String.split(input, " ", parts: 2)
    [content, rest] = String.split(rest, "</.#{tag}>", parts: 2)
    [attrs, content] = String.split(content, ">", parts: 2)

    inner_content = Md.Parser.generate(content)

    assigns =
      attrs
      |> String.trim()
      |> String.split(~r|\s+|)
      |> Enum.reduce(%{__changed__: %{}, inner_block: inner_content}, fn attr, acc ->
        [key, value] = String.split(attr, "=", parts: 2)
        value = String.trim(value, "\"")

        Map.put(acc, String.to_atom(key), value)
      end)

    rendered = apply(Website.Components, String.to_atom(tag), [assigns])

    rendered_html =
      Phoenix.HTML.Safe.to_iodata(rendered)
      |> IO.chardata_to_string()

    {rest, %State{state | ast: [rendered_html | state.ast]}}
  end
end
