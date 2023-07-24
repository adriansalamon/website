defmodule Website.Components do
  use Phoenix.Component
  import Phoenix.HTML
  import Website.LiveReload.LiveReloadComponent

  embed_templates "components/*"

  attr :title, :string, required: true
  attr :intro, :string, required: true
  slot :inner_block

  def simple_layout(assings)

  attr :page, :atom, default: nil
  slot :inner_block
  slot :head

  def layout(assigns)

  attr :as, :string, default: "div"
  attr :class, :string, default: ""

  slot :eyebrow do
    attr :as, :string
    attr :decorate, :boolean
    attr :class, :string
  end

  slot :link do
    attr :href, :string, required: true
  end

  slot :title do
    attr :href, :string, required: false
  end

  slot :cta, required: false
  slot :description
  slot :inner_block

  def card(assigns)

  slot :inner_block
  attr :class, :string, default: ""
  attr :rest, :global

  def container(assigns) do
    ~H"""
    <.outer_container class={@class} {@rest}>
      <.inner_container>
        <%= render_slot(@inner_block) %>
      </.inner_container>
    </.outer_container>
    """
  end

  attr :class, :string, default: ""
  attr :rest, :global
  slot :inner_block

  defp outer_container(assigns) do
    ~H"""
    <div class={["sm:px-8", @class]} {@rest}>
      <div class="mx-auto max-w-7xl lg:px-8">
        <%= render_slot(@inner_block) %>
      </div>
    </div>
    """
  end

  defp inner_container(assigns) do
    ~H"""
    <div class="relative px-4 sm:px-8 lg:px-12">
      <div class="mx-auto max-w-2xl lg:max-w-5xl">
        <%= render_slot(@inner_block) %>
      </div>
    </div>
    """
  end

  attr :href, :string
  attr :rest, :global
  attr :icon, :atom, values: [:twitter, :linkedin, :github, :instagram]

  def index_social_link(assigns) do
    ~H"""
    <.link navigate={@href} class="group -m-1 p-1" {@rest}>
      <.social_icon name={@icon} class="h-6 w-6 fill-zinc-500 transition group-hover:fill-zinc-600" />
    </.link>
    """
  end

  attr :href, :string
  attr :rest, :global
  attr :icon, :atom, values: [:twitter, :linkedin, :github, :instagram, :mail]
  attr :class, :string, default: ""
  slot :inner_block

  def about_social_link(assigns) do
    ~H"""
    <.link
      navigate={@href}
      class={["group flex text-sm font-medium text-zinc-800 transition hover:text-teal-500", @class]}
      {@rest}
    >
      <.social_icon name={@icon} class="h-6 w-6 fill-zinc-500 transition group-hover:fill-teal-500" />
      <span class="ml-4">
        <%= render_slot(@inner_block) %>
      </span>
    </.link>
    """
  end

  attr :name, :atom, required: true
  attr :outline, :boolean, default: false
  attr :solid, :boolean, default: false
  attr :mini, :boolean, default: false
  attr :rest, :global, default: %{class: "w-4 h-4 inline_block"}

  def icon(assigns) do
    assigns = assign_new(assigns, :"aria-hidden", fn -> !Map.has_key?(assigns, :"aria-label") end)

    ~H"""
    <%= apply(Heroicons, @name, [assigns]) %>
    """
  end

  attr :href, :string
  attr :name, :string
  attr :active, :boolean, default: false

  defp nav_link(assigns) do
    ~H"""
    <.link
      href={@href}
      class={[
        "font-medium hover:text-zinc-800",
        (@active && "text-zinc-800") || " text-zinc-500"
      ]}
    >
      <%= @name %>
    </.link>
    """
  end

  attr :href, :string, required: false
  attr :src, :string
  attr :class, :string, default: ""
  attr :small, :boolean, default: false
  attr :rest, :global

  def avatar(assigns) do
    ~H"""
    <div class={@class}>
      <div class={[
        "rounded-full overflow-hidden bg-white/90 p-0.5 shadow-lg shadow-zinc-800/5 ring-1 ring-zinc-900/5 backdrop-blur",
        (!@small && "h-8 w-8 sm:h-10 sm:w-10") || "h-7 w-7"
      ]}>
        <.link :if={Map.has_key?(assigns, :href)} href={@href} {@rest} class="pointer-events-auto">
          <.image
            src={@src}
            alt="Avatar"
            class="h-full w-full rounded-full object-cover"
            sizes="2.5rem"
          />
        </.link>
        <img :if={!Map.has_key?(assigns, :href)} src={@src} class="rounded-full object-cover" />
      </div>
    </div>
    """
  end

  attr :name, :atom, values: [:twitter, :linkedin, :github, :instagram, :mail]
  attr :rest, :global

  def social_icon(assigns) do
    ~H"""
    <svg :if={@name == :twitter} {@rest} viewBox="0 0 24 24" aria-hidden="true">
      <path d="M20.055 7.983c.011.174.011.347.011.523 0 5.338-3.92 11.494-11.09 11.494v-.003A10.755 10.755 0 0 1 3 18.186c.308.038.618.057.928.058a7.655 7.655 0 0 0 4.841-1.733c-1.668-.032-3.13-1.16-3.642-2.805a3.753 3.753 0 0 0 1.76-.07C5.07 13.256 3.76 11.6 3.76 9.676v-.05a3.77 3.77 0 0 0 1.77.505C3.816 8.945 3.288 6.583 4.322 4.737c1.98 2.524 4.9 4.058 8.034 4.22a4.137 4.137 0 0 1 1.128-3.86A3.807 3.807 0 0 1 19 5.274a7.657 7.657 0 0 0 2.475-.98c-.29.934-.9 1.729-1.713 2.233A7.54 7.54 0 0 0 22 5.89a8.084 8.084 0 0 1-1.945 2.093Z" />
    </svg>
    <svg :if={@name == :instagram} {@rest} viewBox="0 0 24 24" aria-hidden="true">
      <path d="M12 3c-2.444 0-2.75.01-3.71.054-.959.044-1.613.196-2.185.418A4.412 4.412 0 0 0 4.51 4.511c-.5.5-.809 1.002-1.039 1.594-.222.572-.374 1.226-.418 2.184C3.01 9.25 3 9.556 3 12s.01 2.75.054 3.71c.044.959.196 1.613.418 2.185.23.592.538 1.094 1.039 1.595.5.5 1.002.808 1.594 1.038.572.222 1.226.374 2.184.418C9.25 20.99 9.556 21 12 21s2.75-.01 3.71-.054c.959-.044 1.613-.196 2.185-.419a4.412 4.412 0 0 0 1.595-1.038c.5-.5.808-1.002 1.038-1.594.222-.572.374-1.226.418-2.184.044-.96.054-1.267.054-3.711s-.01-2.75-.054-3.71c-.044-.959-.196-1.613-.419-2.185A4.412 4.412 0 0 0 19.49 4.51c-.5-.5-1.002-.809-1.594-1.039-.572-.222-1.226-.374-2.184-.418C14.75 3.01 14.444 3 12 3Zm0 1.622c2.403 0 2.688.009 3.637.052.877.04 1.354.187 1.67.31.421.163.72.358 1.036.673.315.315.51.615.673 1.035.123.317.27.794.31 1.671.043.95.052 1.234.052 3.637s-.009 2.688-.052 3.637c-.04.877-.187 1.354-.31 1.67-.163.421-.358.72-.673 1.036a2.79 2.79 0 0 1-1.035.673c-.317.123-.794.27-1.671.31-.95.043-1.234.052-3.637.052s-2.688-.009-3.637-.052c-.877-.04-1.354-.187-1.67-.31a2.789 2.789 0 0 1-1.036-.673 2.79 2.79 0 0 1-.673-1.035c-.123-.317-.27-.794-.31-1.671-.043-.95-.052-1.234-.052-3.637s.009-2.688.052-3.637c.04-.877.187-1.354.31-1.67.163-.421.358-.72.673-1.036.315-.315.615-.51 1.035-.673.317-.123.794-.27 1.671-.31.95-.043 1.234-.052 3.637-.052Z" />
      <path d="M12 15a3 3 0 1 1 0-6 3 3 0 0 1 0 6Zm0-7.622a4.622 4.622 0 1 0 0 9.244 4.622 4.622 0 0 0 0-9.244Zm5.884-.182a1.08 1.08 0 1 1-2.16 0 1.08 1.08 0 0 1 2.16 0Z" />
    </svg>
    <svg :if={@name == :github} {@rest} viewBox="0 0 24 24" aria-hidden="true">
      <path
        fillRule="evenodd"
        clipRule="evenodd"
        d="M12 2C6.475 2 2 6.588 2 12.253c0 4.537 2.862 8.369 6.838 9.727.5.09.687-.218.687-.487 0-.243-.013-1.05-.013-1.91C7 20.059 6.35 18.957 6.15 18.38c-.113-.295-.6-1.205-1.025-1.448-.35-.192-.85-.667-.013-.68.788-.012 1.35.744 1.538 1.051.9 1.551 2.338 1.116 2.912.846.088-.666.35-1.115.638-1.371-2.225-.256-4.55-1.14-4.55-5.062 0-1.115.387-2.038 1.025-2.756-.1-.256-.45-1.307.1-2.717 0 0 .837-.269 2.75 1.051.8-.23 1.65-.346 2.5-.346.85 0 1.7.115 2.5.346 1.912-1.333 2.75-1.05 2.75-1.05.55 1.409.2 2.46.1 2.716.637.718 1.025 1.628 1.025 2.756 0 3.934-2.337 4.806-4.562 5.062.362.32.675.936.675 1.897 0 1.371-.013 2.473-.013 2.82 0 .268.188.589.688.486a10.039 10.039 0 0 0 4.932-3.74A10.447 10.447 0 0 0 22 12.253C22 6.588 17.525 2 12 2Z"
      />
    </svg>
    <svg :if={@name == :linkedin} {@rest} viewBox="0 0 24 24" aria-hidden="true">
      <path d="M18.335 18.339H15.67v-4.177c0-.996-.02-2.278-1.39-2.278-1.389 0-1.601 1.084-1.601 2.205v4.25h-2.666V9.75h2.56v1.17h.035c.358-.674 1.228-1.387 2.528-1.387 2.7 0 3.2 1.778 3.2 4.091v4.715zM7.003 8.575a1.546 1.546 0 01-1.548-1.549 1.548 1.548 0 111.547 1.549zm1.336 9.764H5.666V9.75H8.34v8.589zM19.67 3H4.329C3.593 3 3 3.58 3 4.297v15.406C3 20.42 3.594 21 4.328 21h15.338C20.4 21 21 20.42 21 19.703V4.297C21 3.58 20.4 3 19.666 3h.003z" />
    </svg>
    <svg :if={@name == :mail} {@rest} viewBox="0 0 24 24" aria-hidden="true">
      <path
        fill-rule="evenodd"
        d="M6 5a3 3 0 0 0-3 3v8a3 3 0 0 0 3 3h12a3 3 0 0 0 3-3V8a3 3 0 0 0-3-3H6Zm.245 2.187a.75.75 0 0 0-.99 1.126l6.25 5.5a.75.75 0 0 0 .99 0l6.25-5.5a.75.75 0 0 0-.99-1.126L12 12.251 6.245 7.187Z"
      >
      </path>
    </svg>
    """
  end

  def format_date(date), do: Calendar.strftime(date, "%B %d, %Y")

  attr :src, :string, required: true
  attr :sizes, :string, default: ""
  attr :rest, :global

  def image(assigns) do
    if String.starts_with?(assigns.src, "/"),
      do: static_image(assigns),
      else: external_image(assigns)
  end

  defp static_image(%{src: source} = assigns) do
    alias Website.Images

    with true <- Images.file_exists?(source),
         paths <- Images.generate_variants(source) do
      srcset =
        Enum.map(paths, fn path -> "#{path.path} #{path.w}w" end)
        |> Enum.join(", ")

      assigns =
        assigns
        |> assign(:largest, List.last(paths).path)
        |> assign(:srcset, srcset)

      ~H"""
      <img src={@largest} srcset={@srcset} sizes={@sizes} {@rest} loading="lazy" />
      """
    else
      _ -> external_image(assigns)
    end
  end

  defp external_image(assigns) do
    ~H"""
    <img src={@src} {@rest} />
    """
  end

  def callout(assigns) do
    ~H"""
    <div class="rounded-lg border border-teal-200 bg-teal-50 px-8 py-4 shadow-sm lg:-mx-8">
      <div class="flex flex-row items-center">
        <.icon name={:information_circle} class="mr-2 h-6 w-6" />
        <div class="prose-p:m-0">
          <%= render_slot(@inner_block) %>
        </div>
      </div>
    </div>
    """
  end

  attr :class, :string, default: ""

  def not_prose(assigns) do
    ~H"""
    <div class={["not-prose", @class]}>
      <%= render_slot(@inner_block) %>
    </div>
    """
  end
end
