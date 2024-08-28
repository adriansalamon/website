defmodule Website.Build.HEEXParser do
  require Phoenix.LiveView.TagEngine
  alias Md.Parser.State

  @behaviour Md.Parser

  @impl true
  def parse(input, state \\ %State{})

  def parse(input, state) do
    {tag, attrs, content, rest} = split_input(input)

    assigns = get_assigns(attrs, content)

    # The tag is a component, which is just a function, we call it
    rendered_html =
      apply(Website.Components, String.to_atom(tag), [assigns])
      |> Phoenix.HTML.Safe.to_iodata()
      |> IO.chardata_to_string()

    {rest, %State{state | ast: [rendered_html | state.ast]}}
  end

  defp split_input(input) do
    [top_tag, rest] =
      String.split(input, ">", parts: 2)

    self_closing = String.ends_with?(top_tag, "/")

    {tag, attrs} = lex_top_tag(top_tag)

    {content, rest} =
      if self_closing do
        {"", rest}
      else
        split_content(tag, rest)
      end

    {tag, attrs, content, rest}
  end

  defp lex_top_tag(top_tag) do
    # first word is **always** the tag, the rest are key="val1 val2" attributes
    case String.split(top_tag, ~r{\s}, parts: 2) do
      [tag] ->
        {tag, %{}}

      [tag, attrs] ->
        attrs =
          Regex.scan(~r/(\w+)="([^"]*)"/, attrs)
          |> Enum.reduce(
            %{},
            fn [_, key, value], acc ->
              Map.put(acc, String.to_atom(key), value)
            end
          )

        {tag, attrs}
    end
  end

  defp split_content(tag, rest), do: split_content(tag, "", rest)

  defp split_content(tag, content, rest) do
    [inner_content, rest] = String.split(rest, "</.#{tag}>", parts: 2)

    # If there is another tag inside the content, we need to split it
    # again
    if String.contains?(inner_content, "<.#{tag}") do
      split_content(tag, content <> inner_content <> "</.#{tag}>", rest)
    else
      {content <> inner_content, rest}
    end
  end

  defp get_assigns(attrs, content) do
    # To render the inner_block slot, we need to compile the content
    # of the tag and then evaluate it.

    quoted =
      content
      |> Md.Parser.generate()
      |> EEx.compile_string(engine: Phoenix.LiveView.Engine)

    {inner_block, _bindings} = Code.eval_quoted(quoted, assigns: %{})

    # LiveView expects the inner_block slot to be a function with two
    # arguments that returns the result of rendering the inner content

    assigns = %{
      __changed__: %{},
      inner_block: %{__slot__: :inner_block, inner_block: fn _, _ -> inner_block end}
    }

    Map.merge(assigns, attrs)
  end
end
