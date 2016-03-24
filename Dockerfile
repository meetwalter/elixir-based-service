FROM meetwalter/erlang-based-service:18.3
MAINTAINER Michael Williams
ENV REFRESHED_AT 2016-03-23

# Set correct environment variables.
ENV ELIXIR_MAJOR 1.2
ENV ELIXIR_VERSION 1.2.3

# Build Elixir from source and install it.
RUN mkdir -p /usr/src/erlang \
  && git clone --branch v1.2.3 --depth 1 https://github.com/elixir-lang/elixir.git /usr/src/elixir \
  && cd /usr/src/elixir \
  && make \
  && make install \
  && rm -r /usr/src/elixir

# Clean up.
RUN rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*
