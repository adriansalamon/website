defmodule Website.LiveReload.IndexHtml do
  @behaviour Plug

  def init([]), do: init(default_file: "index.html")
  def init(default_file: filename), do: [default_file: filename]

  def call(conn, default_file: filename) do
    accept = Plug.Conn.get_req_header(conn, "accept")

    if Enum.any?(accept, &String.contains?(&1, "text/html")) do
      cond do
        String.match?(conn.request_path, ~r|^/(.*/)?$|) ->
          %{
            conn
            | request_path: "#{conn.request_path}#{filename}",
              path_info: conn.path_info ++ [filename]
          }

        String.match?(conn.request_path, ~r|^([^.]+)$|) ->
          %{
            conn
            | request_path: "#{conn.request_path}/#{filename}",
              path_info: conn.path_info ++ [filename]
          }

        true ->
          conn
      end
    else
      conn
    end
  end
end
