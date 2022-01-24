# BUILD
FROM elixir:1.12 AS build

COPY . .
RUN mix do local.hex --force, local.rebar --force

ENV MIX_ENV=prod
RUN mix deps.get && \
  mix release && \
  mix assets.deploy

RUN mkdir /jarvis && \
  cp -r _build/prod/rel/jarvis /jarvis

# RUNTIME
FROM elixir:1.12-slim
LABEL maintainer="corka149 <corka149@mailbox.org>"

COPY --from=build /jarvis .

## Security
RUN groupadd -r jarvis && useradd -r -s /bin/false -g jarvis jarvis
RUN chown -R jarvis:jarvis /jarvis

## RUN
USER jarvis
EXPOSE 4000 4001
ENTRYPOINT ["/jarvis/bin/jarvis"]
CMD ["start"]
