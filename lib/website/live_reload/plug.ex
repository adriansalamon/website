defmodule Website.LiveReload.Plug do
  import Plug.Conn

  @behaviour Plug

  reload_path = "priv/js/live_reload.js"
  @external_resource reload_path

  @html_before """
  <html><body>
  <script>
  """

  @html_after """
  #{File.read!(reload_path)}
  </script>
  </body></html>
  """

  def init(opts) do
    opts
  end

  def call(%Plug.Conn{path_info: ["live_reload", "frame" | _suffix]} = conn, opts) do
    interval = opts[:interval] || 100

    conn
    |> put_resp_content_type("text/html")
    |> send_resp(200, [
      @html_before,
      ~s[var interval = #{interval};\n],
      @html_after
    ])
    |> halt()
  end

  def call(conn, opts) do
    register_before_send(conn, fn conn ->
      if conn.resp_body != nil and html?(conn) do
        resp_body = IO.iodata_to_binary(conn.resp_body)

        if has_body?(resp_body) do
          [page | rest] = String.split(resp_body, "</body>")
          body = [page, reload_assets_tag(opts), "</body>" | rest]
          put_in(conn.resp_body, body)
        else
          conn
        end
      else
        conn
      end
    end)
  end

  defp html?(conn) do
    case get_resp_header(conn, "content-type") do
      [] -> false
      [type | _] -> String.starts_with?(type, "text/html")
    end
  end

  defp has_body?(resp_body), do: String.contains?(resp_body, "<body")

  defp reload_assets_tag(opts) do
    attrs =
      Keyword.merge(
        [src: "/live_reload/frame", hidden: true, height: 0, width: 0],
        Keyword.get(opts, :iframe_attrs, [])
      )

    IO.iodata_to_binary(["<iframe", attrs(attrs), "></iframe>"])
  end

  defp attrs(attrs) do
    Enum.map(attrs, fn
      {_key, nil} -> []
      {_key, false} -> []
      {key, true} -> [?\s, key(key)]
      {key, value} -> [?\s, key(key), ?=, ?", value(value), ?"]
    end)
  end

  defp key(key) do
    key
    |> to_string()
    |> String.replace("_", "-")
    |> Plug.HTML.html_escape_to_iodata()
  end

  defp value(value) do
    value
    |> to_string()
    |> Plug.HTML.html_escape_to_iodata()
  end
end
