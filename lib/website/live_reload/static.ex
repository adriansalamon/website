defmodule Website.LiveReload.StaticHTML do
  @moduledoc """
  Plug for serving static HTML files, by
  reading them from the filesystem and then serving them.

  The code here is stolen directly from Plug.Static, with the main difference
  being that we read the file from the filesystem and then serve it, rather
  than serving it directly from the filesystem.

  This is useful when you want to serve static HTML files, but you want to
  inject some data into them before serving them, eg. injecting code
  for live reloading.
  """
  @behaviour Plug
  @allowed_methods ~w(GET)

  import Plug.Conn
  alias Plug.Conn

  defmodule InvalidPathError do
    defexception message: "invalid path for static asset", plug_status: 400
  end

  @impl true
  def init(opts) do
    from =
      case Keyword.fetch!(opts, :from) do
        {_, _} = from -> from
        {_, _, _} = from -> from
        from when is_atom(from) -> {from, "priv/static"}
        from when is_binary(from) -> from
        _ -> raise ArgumentError, ":from must be an atom, a binary or a tuple"
      end

    %{
      only_rules: {Keyword.get(opts, :only, []), Keyword.get(opts, :only_matching, [])},
      headers: Keyword.get(opts, :headers, %{}),
      content_types: Keyword.get(opts, :content_types, %{}),
      from: from,
      at: opts |> Keyword.fetch!(:at) |> Plug.Router.Utils.split()
    }
  end

  @impl true
  def call(
        conn = %Conn{method: meth},
        %{at: at, only_rules: only_rules, from: from} = options
      )
      when meth in @allowed_methods do
    segments = subset(at, conn.path_info)

    if allowed?(only_rules, segments) do
      segments = Enum.map(segments, &uri_decode/1)

      if invalid_path?(segments) do
        raise InvalidPathError, "invalid path for static asset: #{conn.request_path}"
      end

      path = path(from, segments)

      serve_static(conn, path, segments, options)
    else
      conn
    end
  end

  def call(conn, _options) do
    conn
  end

  defp uri_decode(path) do
    # TODO: Remove rescue as this can't fail from Elixir v1.13
    try do
      URI.decode(path)
    rescue
      ArgumentError ->
        raise InvalidPathError
    end
  end

  defp allowed?(_only_rules, []), do: false
  defp allowed?({[], []}, _list), do: true

  defp allowed?({full, prefix}, [h | _]) do
    h in full or (prefix != [] and match?({0, _}, :binary.match(h, prefix)))
  end

  defp serve_static(conn, path, segments, options) do
    %{
      headers: headers,
      content_types: types
    } = options

    filename = List.last(segments)
    content_type = Map.get(types, filename) || MIME.from_path(filename)

    case File.read(path) do
      {:ok, data} ->
        conn
        |> put_resp_header("content-type", content_type)
        |> put_resp_header("accept-ranges", "bytes")
        |> merge_headers(headers)
        |> send_resp(200, data)
        |> halt()

      {:error, _} ->
        conn
    end
  end

  defp path({module, function, arguments}, segments)
       when is_atom(module) and is_atom(function) and is_list(arguments),
       do: Enum.join([apply(module, function, arguments) | segments], "/")

  defp path({app, from}, segments) when is_atom(app) and is_binary(from),
    do: Enum.join([Application.app_dir(app), from | segments], "/")

  defp path(from, segments),
    do: Enum.join([from | segments], "/")

  defp subset([h | expected], [h | actual]), do: subset(expected, actual)
  defp subset([], actual), do: actual
  defp subset(_, _), do: []

  defp invalid_path?(list) do
    invalid_path?(list, :binary.compile_pattern(["/", "\\", ":", "\0"]))
  end

  defp invalid_path?([h | _], _match) when h in [".", "..", ""], do: true
  defp invalid_path?([h | t], match), do: String.contains?(h, match) or invalid_path?(t)
  defp invalid_path?([], _match), do: false

  defp merge_headers(conn, {module, function, args}) do
    merge_headers(conn, apply(module, function, [conn | args]))
  end

  defp merge_headers(conn, headers) do
    merge_resp_headers(conn, headers)
  end
end
