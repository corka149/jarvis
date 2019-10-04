FROM elixir:1.9.1-alpine AS build

COPY . .

RUN \
    mkdir -p /opt/app && \
    chmod -R 777 /opt/app && \
    apk update && \
    apk --no-cache --update add \
      git \
      make \
      g++ \
      wget \
      curl \
      inotify-tools \
      nodejs \
      nodejs-npm && \
    npm install npm -g --no-progress && \
    update-ca-certificates --fresh && \
    rm -rf /var/cache/apk/*

ENV PATH=./node_modules/.bin:$PATH

RUN mix do local.hex --force, local.rebar --force

ENV MIX_ENV=prod
RUN mix deps.get
RUN npm install --prefix assets
RUN npm run deploy --prefix assets
RUN mix phx.digest
RUN mix release

RUN mkdir /jarvis && \
    cp -r _build/prod/rel/jarvis /jarvis

FROM alpine

RUN apk add --no-cache openssl && \
    apk add --no-cache ncurses-libs

LABEL maintainer="corka149 <corka149@mailbox.org>"

COPY --from=build /jarvis .

EXPOSE 4000

ENTRYPOINT ["/jarvis/bin/jarvis"]
CMD ["start"]
