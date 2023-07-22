#!/bin/sh

mkdir ~/.local/share/fonts

cp /priv/fonts/* ~/.local/share/fonts

fc-cache -f -v