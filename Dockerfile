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

# Install Hex and Rebar.
RUN /usr/local/bin/mix local.hex --force \
  && /usr/local/bin/mix local.rebar --force

# Clean up.
RUN rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

# Run the microservice.
RUN mkdir /etc/service/app
ADD boot.sh /etc/service/app/run
