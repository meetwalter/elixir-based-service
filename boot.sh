#!/bin/sh

cd /app

mix do deps.get, deps.compile --all, compile
mix start
