%{
title: "Crafting a feature-rich static site generator in Elixir",
author: "Adrian Salamon",
description: "How I created my own fast and feature-rich static site generator in Elixir for my personal website.",
tags: ~w()
}

---

Welcome to my little website! This is the my first ever post that accompanies
this site. Making a personal website in 2023 might not seem like the most
complex task, and you would be right. There are many (probably fantastic) tools
out there that can help you with easily creating static website.

Instead of choosing the easy path, I decided to create my own static site
generator (SSG). Being an avid Elixir fan, I decided to use it as the language
of choice for this project. A good question might be **why?** There are a few
reasons. 

Firstly, I really love writing Elixir code. It allows me to write
expressive code that "Just Works", has powerful features like macros, and
a good community and ecosystem of useful libraries. Secondly, I was inspired by
some good resources, most notably the `NimblePublisher` library developed
by Dashbit and the accompanying article
[Welcome to our blog: how it was made!](https://dashbit.co/blog/welcome-to-our-blog-how-it-was-made).

This post builds on top of the article titled 
[Crafting your own Static Site Generator using Phoenix](https://fly.io/phoenix-files/crafting-your-own-static-site-generator-using-phoenix/)
by Jason Stiebs. I recommend reading it for a
more in-depth explanation of how to create a really simple SSG using Elixir and
Phoenix. The basic idea is to use `NimblePublisher` to generate posts in Elixir
using markdown files as input. The generated posts are then rendered using
`HEEx` function components, and the resulting HTML is written to files in 
an output folder. The generated HTML files can then be served using a static file 
server or deployed to a CDN. My website is based on the same basic idea, but has 
the following nice additions:

- It has a development mode that hosts the site locally using `Bandit` and
  `Plug`.
- The development mode watches for changes in the source files, automatically
  recompiles them and reloads the browser.
- It allows for using `HEEx` components inside markdown files, for more
  expressive content.
- It has a can optimize images at compile-time and generate different image
  sizes using the `Image` library.
- It has SEO tags for posts that makes then render nicely when shared on social
  media. This includes automatically generating a nice image for each post.

## Why roll your own SSG?

There are many SSGs out there, including ones written in Elixir. One intriguing
option is [Tableau](https://github.com/elixir-tools/tableau), which looks like
a nice library, but seems to be mainly focused using it together with the Temple
templating engine. As i really enjoy working with `HEEx` in Phoenix and Phoenix
LiveView, so I wanted to use `HHEx` components to create whole website.

I am considering making this project into a library, as I see it as being useful
for creating static websites with Elixir. However, I think there is still some
merit in just using it as a starting point for your own website. Most people
will have different requirements for their website, and not using a
opinionated library will make your site endlessly more hackable. For now,
I have decided to keep it as an open source standalone example project.

I will briefly describe some of the more interesting and hopefully useful parts
of the project, that builds on top of the original article by Jason Stiebs.

## Development mode

I am so used to having a nice development mode that automatically reloads the
browser when I make changes to the code, that I just had to add it to my SSG. My
implementation is based on the way Phoenix works. The gist of it is that I have
a `Bandit` server that serves the built site locally using the `Plug.Static`
module. On each request, the server rebuilds the site and serves the new
version. In the development mode, the web browser establishes a websocket
connection to the server. There is also a `FileSystem` process that watches for
changes in source files. When it detects a change, it sends a message to the
client to reload the page, and also initiates a recompile of changed modules.

## HEEx components in markdown

I really like the idea of using `HEEx` components in markdown files. It allows
me to create reusable components with custom styling inside of my markdown posts.
This is an example of such a component:

<.callout>
  This is content **inside** of a `HEEx` component.
</.callout>

The component is defined in the following way:

```elixir
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
```

And called from markdown like this:

```markdown
<.callout>
  This is content **inside** of a `HEEx` component.
</.callout>
```

My implementation of this is kind of hacky, but it works 🤷‍♂️. I had to submit
a [PR](https://github.com/dashbitco/nimble_publisher/pull/28) to
`NimblePublisher` to make it work, and use the
[`Md`](https://github.com/am-kantox/md) library. This library enables the use of
custom parsers in markdown files. I created a custom parser for `HEEx`, that is
loosely based on
[this](https://elixirforum.com/t/implementing-custom-markdown-parser-with-the-md-library/55025/8?u=adriansalamon)
forum post. Since function components in `HEEx` are just plain old functions,
whenever we encounter a tag that starts with `<.`, we can just call the function
component as a function. The result of this function is a `%LiveView.Rendered{}` struct,
which we can then convert into a string using `Phoenix.HTML.Safe` and add it
to the rendered HTML, like this:

```elixir
defmodule Website.Build.HEEXParser do
  alias Md.Parser.State

  @behaviour Md.Parser

  @impl true
  def parse(input, state \\ %State{})

  def parse(input, state) do
    {tag, attrs, content, rest} = split_input(input)

    assigns = get_assigns(attrs, content)

    # The tag is a component, which is just a function, we call it
    rendered_html =
      apply(Website.Components, String.to_existing_atom(tag), [assigns])
      |> Phoenix.HTML.Safe.to_iodata()
      |> IO.chardata_to_string()

    {rest, %State{state | ast: [rendered_html | state.ast]}}
  end
  
  ...
end
```

We need to add the `HEEx` parser as a custom parser in `Md` in our
`config/config.exs` file:

```elixir
config :md,
  syntax: %{
    custom: [{"<.", {Website.Build.HEEXParser, %{}}}]
  }
```

And finally we need to create a custom markdown converter (this is what my PR added
☺️) that replaces the default `Earmark` markdown parser with `Md` in `NimblePublisher`:

```elixir
defmodule Website.Build.HTMLConverter do
  def convert(extname, content, _attrs, opts) when extname in [".md"] do
    highlighters = Keyword.get(opts, :highlighters, [])

    Md.generate(content, format: :none) |> NimblePublisher.highlight(highlighters)
  end
end
```

And add `html_converter: Website.Build.HTMLConverter` when using the `NimblePublisher`
module.

Some care needs to be taken to make sure that we can inject rendered markdown
content into the `inner_block` slot of the component. This is done by
recursively rendering the inner block of the component using `Md`, then
converting the result into `EEx` using the `LiveView` engine, and finally
assigning the result to the `inner_block` slot of the component. Check out
the [full source code](https://github.com/adriansalamon/website/blob/main/lib/website/build/heex_parser.ex) 
for more details.

## Image optimization

Sending large full-size images over the network is both slow and wasteful. I
wanted to have a good way of automatically optimizing images for my website.
HTML image tags have a `srcset` attribute that allows the browser to choose the
best image size for the current screen size. In order to use this, we need to
generate multiple versions of each image in different sizes when building the
site. While slightly abusing the notion of a function (this is a non-pure
function with side effects), this sounds like a good use of a `HEEx` function
component. Since I can use `HEEx` components in markdown files, I can have
optimized images in my posts without having to worry about it! It is implemented
in the following way:

```elixir
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
```

The bulk of the work is done in the `Images.generate_variants/1` function, which
idempotently generates different image sizes using the `Image` library. Since image
variants are only generated once, this does not slow down the build time when
developing the site. The function is implemented in the following way:

```elixir
@content_dir Application.compile_env(:website, :content_dir, "priv/")
@output_dir Application.compile_env(:website, :output_dir, "output")
@output_path "#{@output_dir}/assets/static"
@breakpoints [16, 32, 48, 64, 96, 128, 256, 384, 640, 750, 828, 1080, 1200, 1920]

def generate_variants(path, options \\ []) do
  breakpoints = Keyword.get(options, :breakpoints, @breakpoints)
  format = Keyword.get(options, :format, "webp")

  path = Path.join(@content_dir, path)
  image = Image.open!(path)

  for breakpoint <- breakpoints do
    file_name = Path.split(path) |> List.last() |> String.split(".") |> hd()
    out_path = Path.join(@output_path, "#{file_name}-#{breakpoint}.#{format}")

    if !File.exists?(out_path) do
      File.mkdir_p!(Path.dirname(out_path))

      Image.thumbnail!(image, breakpoint)
      |> Image.write!(out_path)
    end

    %{path: String.trim_leading(out_path, @output_dir), w: breakpoint}
  end
end
```

This function reads the image from the source directory, and for each breakpoint
generates a new image with the given width. The generated images are saved to
the output directory, and their paths and widths are returned.

## SEO tags for posts

I wanted to have nice SEO tags for my posts, so that they render nicely when
shared on social media. When sharing a link on a social media site such as
Twitter, the site will try to fetch some specific tags from the page that
describes the content of the page. These tags include the title, description,
author and a preview image. The image is used as a preview when sharing the
link on social media.

For generating the tags, i used the [phoenix\_seo](https://github.com/dbernheisel/phoenix_seo/)
library. Despite Phoenix being in the name, it works just fine without Phoenix. 
I followed the instructions in the README file, and just and added the following
when generating the HTML for each post:

```elixir
for post <- posts do
  conn = SEO.assign(%Plug.Conn{}, post)
  render_file(post.path, post(%{post: post, conn: conn}))
end
```

And added the `SEO.Juice` component to my post `HEEx` component:

```elixir
<.layout>
  <:head>
    <SEO.juice conn={@conn} config={Website.SEO.config()} page_title={@post.title} />
  </:head>
  ...
</.layout>
```

### Generating preview images

While rapidly falling into the rabbit hole of SEO, I wanted to automatically
generate some nice-looking preview images for my posts. My approach is inspired by the
blog post [Dynamic image generation with Elixir](https://danschultzer.com/posts/dynamic-image-generation-with-elixir),
which uses the `Image` library.

I created a background image in Photoshop, and an svg file with the text that
should be rendered on top of the background image. I can then use the `Image`
library to render the svg file on top of the background image, and save the
result as a new image. The code for this is quite simple. I have an svg file
with placeholders for each line in the title eg. `LINE_1`, `LINE_2`, ... (svg
does not support wrapping text). We split the title of the post into chunks of
words that fit on a single line, and replace the placeholders in the svg file
with the chunks. We then render the svg file on top of the background image,
and save the result as a new image. The code for this is shown below:

```elixir
@max_length 28
@tags ~w(LINE_1 LINE_2 LINE_3 LINE_4)

def generate_og_image(post) do
  output_path = Path.join(@output_dir, ["assets/static/og-images/", post.id, ".jpg"])
  File.mkdir_p!(Path.dirname(output_path))

  text_overlay =
    String.split(post.title, " ")
    |> Enum.reduce([], &wrap_words/2)
    |> Enum.reverse()
    |> replace_headings()
    |> Image.from_svg!()

  base_image = Image.open!(Path.join(@content_dir, "assets/static/og-background.png"))

  avatar_image =
    Image.open!(Path.join(@content_dir, "assets/static/profile.jpeg"))
    |> Image.avatar!(size: 65)

  Image.compose!(base_image, avatar_image, x: 58, y: 516)
  |> Image.compose!(text_overlay)
  |> Image.write!(output_path)

  String.trim_leading(output_path, @output_dir)
end

defp wrap_words(word, [curr | rest] = acc) do
  concatinated = curr <> " " <> word

  if String.length(concatinated) > @max_length do
    [word | acc]
  else
    [concatinated | rest]
  end
end

defp wrap_words(word, []), do: [word]

defp replace_headings(headings) do
  {svg, _} =
    Enum.reduce(@tags, {@svg, headings}, fn tag, {svg, headings} ->
      case headings do
        [] -> {String.replace(svg, tag, ""), []}
        [head | rest] -> {String.replace(svg, tag, head), rest}
      end
    end)

  svg
end
```

The path of the generated image is returned from the `generate_og_image/1`
function and is used in the `SEO.OpenGraph.Build` implementation for posts:

```elixir
defimpl SEO.OpenGraph.Build, for: Website.Build.Posts.Post do
  def build(post, _conn) do
    SEO.OpenGraph.build(
      ...,
      image: image(post)
    )
  end

  defp image(post) do
    path = Website.Images.generate_og_image(post)

    SEO.OpenGraph.Image.build(
      url: path,
      width: 1200,
      height: 630,
      alt: post.title
    )
  end
end
```

This results in the following nice-looking preview image when sharing a link:

<.image src="/assets/static/og-images/crafting-elixir-ssg.jpg" alt="OG image" />
## Conclusion

In the end, was it worth it to create my own SSG? I think so. I have learnt a lot
about how `EEx` and `HEEx` works, and I have created a website that I am happy
with. It is fast, easy to work with, and has all the features that I want it to
have. The best part is that if there is anything that I want to change, or a 
feature that I want to add, I can just do it. The full source code for my website
is available on [GitHub](https://github.com/adriansalamon/website).

I hope that some of the ideas in this post and the source code for my website is
useful or interesting. If you have any questions, comments or tips for
improvement, feel free to reach out to me on
[Twitter](https://twitter.com/adriansalamon). 