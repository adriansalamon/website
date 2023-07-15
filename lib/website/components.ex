defmodule Website.Components do
  use Phoenix.Component
  import Phoenix.HTML

  embed_templates "components/*"

  attr :page, :atom, default: nil
  slot :inner_block
  def layout(assigns)

  attr :as, :string, default: "div"

  slot :eyebrow do
    attr :as, :string
    attr :decorate, :boolean
  end

  slot :link do
    attr :href, :string, required: true
  end

  slot :title do
    attr :href, :string, required: false
  end

  slot :cta, required: false
  slot :description

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

  def social_link(assigns) do
    ~H"""
    <.link navigate={@href} class="group -m-1 p-1" {@rest}>
      <.icon
        name={:academic_cap}
        solid
        class="w-6 h-6 fill-zinc-500 transition group-hover:fill-zinc-600"
      />
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
        "text-zinc-500 hover:text-zinc-800",
        (@active && "link-underline-active text-zinc-800") || "link-underline"
      ]}
      aria-link={@name}
    >
      <%= @name %>
    </.link>
    """
  end
end
