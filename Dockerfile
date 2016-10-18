FROM elixir:1.3

RUN mix do local.hex --force, local.rebar --force

COPY ./bin /usr/local/bin
COPY ./node /node

WORKDIR /node
ENV MIX_ENV=prod

EXPOSE 22

WORKDIR /node/apps/default
RUN mix do deps.get, deps.compile, compile

ENTRYPOINT ["/usr/local/bin/docker-entrypoint"]
CMD ["start"]
