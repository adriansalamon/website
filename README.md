# Website

Personal website built with Elixir. Uses a home-built custom static site
generator.

## Developing

The site can be built and served locally with live reload using:

```bash
mix deps.get
mix site.serve
```

This will build the site and serve it on `localhost:4000`. The site will
automatically rebuild and reload when changes are made.

Also, new posts can easily be created with: `mix site.new_post <name>`.

## Building

Assuming you have a working Elixir installation:

```bash
mix deps.get --only prod
MIX_ENV=prod mix site.build
```

This will generate the site in `_site/`.

Note: For post thumbnail image generation, you need to have the font `Inter`
installed, see `build.sh`.