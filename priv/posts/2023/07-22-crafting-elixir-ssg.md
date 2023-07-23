%{
  title: "Crafting a static site generator in Elixir",
  author: "Adrian Salamon",
  description: "How I created my own fast and feature-rich static site generator in Elixir.",
  tags: ~w()
}
---

Welcome to my little website! This is the my first ever post that accompanies
this site. Making a personal website in 2023 might not seem like the most
complex task, and you would be right. There are many (probably fantastic) tools
out there that can help you with easily creating static website.

Instead of choosing the easy path, I decided to create my own static site
generator (SSG). Being an avid Elixir fan, I decided to use it as the language
of choice for this project. A good question might be **why?**. There are a few
reasons. I really love writing Elixir code. It allows me to write
expressive code that "Just Works", has powerful features like macros, and
a good community and ecosystem of useful libraries.

This post builds on top of the article titled 
[Crafting your own Static Site Generator using Phoenix](https://fly.io/phoenix-files/crafting-your-own-static-site-generator-using-phoenix/)
by [Jason Stiebs](https://twitter.com/peregrine). My website is based on 
the same basic idea, but has the following nice additions:

- It has a development mode that hosts the site locally using `Bandit` and
  `Plug`.
- The development mode watches for changes in the source files, automatically
  recompiles them and reloads the browser.
- It allows for using `HEEx` components inside markdown files, for more
  expressive content.
- It has a can optimize images at compile-time and generate different image
  sizes using `Image` and `Vips`.
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
will have different requirements goals for their website, and not using a
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

<.callout >
  This is content **inside** of a `HEEx` component.
</.callout>

The component is defined in the following way:

```elixir
def callout(assigns) do
  ~H"""
  <div class="bg-teal-50 border-teal-200 shadow-sm border rounded-lg px-4 py-4">
    <div class="flex flex-row items-center">
      <.icon name={:information_circle} class="w-6 h-6 mr-2" />
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
<.callout >
  This is content **inside** of a `HEEx` component.
</.callout>
```

