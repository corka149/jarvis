FROM bitwalker/alpine-elixir-phoenix AS build

COPY . .

RUN export MIX_ENV=prod && \
    npm run deploy --prefix assets && \
    mix deps.get && \
    mix release

RUN mkdir /jarvis && \
    cp -r _build/prod/rel/jarvis /jarvis

FROM alpine

RUN apk add --no-cache openssl && \
    apk add --no-cache ncurses-libs

LABEL maintainer="corka149 <corka149@mailbox.org>"

COPY --from=build /jarvis .

ENTRYPOINT ["/jarvis/bin/jarvis"]
CMD ["start"]
