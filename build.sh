#!/bin/sh

# Install fonts
mkdir -p ~/.local/share/fonts
cp priv/fonts/* ~/.local/share/fonts
fc-cache -f -v
fc-list

# Get deps
mix local.hex --force 
mix local.rebar --force
mix deps.get --only prod

# Build site
MIX_ENV=prod mix site.build