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

  def absolute_url(path) do
    scheme = Application.get_env(:website, :scheme)
    hostname = Application.get_env(:website, :hostname)
    port = Application.get_env(:website, :port)

    "#{scheme}://#{hostname}:#{port}#{path}"
  end
end

defimpl SEO.OpenGraph.Build, for: Website.Build.Posts.Post do
  def build(post, _conn) do
    SEO.OpenGraph.build(
      title: post.title,
      description: post.description,
      url: Website.SEO.absolute_url(post.url),
      detail:
        SEO.OpenGraph.Article.build(
          published_time: post.date,
          author: post.author,
          tags: post.tags
        ),
      image: image(post)
    )
  end

  defp image(post) do
    path = Website.Images.generate_og_image(post)

    SEO.OpenGraph.Image.build(
      url: Website.SEO.absolute_url(path),
      width: 1200,
      height: 630,
      alt: post.title
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
    img_path = Website.Images.generate_og_image(post)

    SEO.Twitter.build(
      card: :summary_large_image,
      description: post.description,
      title: post.title,
      site: "@salamonadrian",
      creator: "@salamonadrian",
      image: Website.SEO.absolute_url(img_path)
    )
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
      %{name: "Posts", item: Website.SEO.absolute_url("/blog")},
      %{name: post.title, item: Website.SEO.absolute_url(post.url)}
    ])
  end
end
