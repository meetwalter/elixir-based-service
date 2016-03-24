#!/bin/bash

mix do deps.get, deps.compile --all, compile
exec mix start
