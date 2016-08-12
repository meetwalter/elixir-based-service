FROM meetwalter/erlang-based-service:18.3
MAINTAINER Michael Williams
ENV REFRESHED_AT 2016-08-12

# Set correct environment variables.
ENV ELIXIR_MAJOR 1.3
ENV ELIXIR_VERSION 1.3.2

# Build Elixir from source and install it.
RUN mkdir -p /usr/src/erlang \
  && git clone --branch v1.3.2 --depth 1 https://github.com/elixir-lang/elixir.git /usr/src/elixir \
  && cd /usr/src/elixir \
  && make \
  && make install \
  && rm -r /usr/src/elixir

# Install Hex and Rebar.
RUN /usr/local/bin/mix local.hex --force \
  && /usr/local/bin/mix hex.info \
  && /usr/local/bin/mix local.rebar --force

# Clean up.
RUN rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

# Run the microservice on boot.
RUN mkdir /etc/service/app
ADD boot.sh /etc/service/app/run
