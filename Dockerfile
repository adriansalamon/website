FROM elixir:1.18-otp-28-alpine AS builder

# vix/libvips native deps + font tools
RUN apk add --no-cache \
    build-base \
    pkgconf \
    vips-dev \
    fontconfig \
    curl

WORKDIR /app

# Install hex + rebar
RUN mix local.hex --force && mix local.rebar --force

ENV MIX_ENV="prod"

COPY mix.exs mix.lock ./
RUN mix deps.get --only $MIX_ENV

COPY config/config.exs config/${MIX_ENV}.exs config/
RUN mix deps.compile

COPY priv priv
COPY lib lib
COPY assets assets

# Install fonts for image processing
RUN mkdir -p ~/.local/share/fonts && \
    cp priv/fonts/* ~/.local/share/fonts && \
    fc-cache -f

# Build the static site
RUN MIX_ENV=prod mix site.build

# ---- Serve stage ----
FROM nginx:alpine

COPY --from=builder /app/_site /usr/share/nginx/html

RUN cat <<'EOF' > /etc/nginx/conf.d/default.conf
server {
    listen 80;
    root /usr/share/nginx/html;
    index index.html;
    absolute_redirect off;

    location / {
        try_files $uri $uri.html $uri/ =404;
    }

    error_page 404 /404.html;

    location /assets/ {
        expires 7d;
        add_header Cache-Control "public";
    }

    location ~* "^/assets/app-[A-z0-9]+\.(css|js)$" {
        expires 3m;
        add_header Cache-Control "public, immutable";
    }
}
EOF

EXPOSE 80
