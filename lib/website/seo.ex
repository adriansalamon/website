defmodule Website.SEO do
  use SEO,
    json_library: Jason,
    site: &__MODULE__.site_config/1,
    open_graph: SEO.OpenGraph.build(locale: "en_US"),
    twitter:
      SEO.Twitter.build(
        site: "@adriansalamon",
        creator: "@adriansalamon"
      )

  def site_config(_conn) do
    SEO.Site.build(
      title_suffix: " - Adrian Salamon",
      default_title: "Adrian Salamon's Blog",
      description: "Adrian Salamon's Blog"
    )
  end
end

defimpl SEO.OpenGraph.Build, for: Website.Build.Posts.Post do
  def build(post, _conn) do
    SEO.OpenGraph.build(
      title: SEO.Utils.truncate(post.title, 70),
      description: SEO.Utils.truncate(post.description, 200),
      url: post.url,
      type: :article,
      type_detail:
        SEO.OpenGraph.Article.build(
          published_time: post.date,
          author: post.author,
          tags: post.tags
        )
    )
  end
end

defimpl SEO.Site.Build, for: Website.Build.Posts.Post do
  def build(post, _conn) do
    SEO.Site.build(
      url: post.url,
      title: SEO.Utils.truncate(post.title, 70),
      description: post.description
    )
  end
end

defimpl SEO.Twitter.Build, for: Website.Build.Posts.Post do
  def build(post, _conn) do
    SEO.Twitter.build(card: :summary, description: post.description, title: post.title)
  end
end

defimpl SEO.Unfurl.Build, for: Website.Build.Posts.Post do
  def build(post, _conn) do
    SEO.Unfurl.build(
      label1: "Reading time",
      data1: format_time(post.reading_time),
      label2: "Published",
      data2: Date.to_iso8601(post.date)
    )
  end

  defp format_time(length), do: "#{length} minutes"
end

defimpl SEO.Breadcrumb.Build, for: Website.Build.Posts.Post do
  def build(post, _conn) do
    SEO.Breadcrumb.List.build([
      %{name: "Posts", item: "/blog"},
      %{name: post.title, item: post.url}
    ])
  end
end
