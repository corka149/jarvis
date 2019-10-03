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

# Set envs for mix
ENV PORT=${PORT}
ENV HOST=${HOST}
ENV DB_PASSWORD=${DB_PASSWORD}
ENV DB_USERNAME=${DB_USERNAME}
ENV DB_NAME=${DB_NAME}
ENV DB_HOST=${DB_HOST}
ENV GITHUB_CLIENT_ID=${GITHUB_CLIENT_ID}
ENV GITHUB_CLIENT_SECRET=${GITHUB_CLIENT_SECRET}
ENV SECRET_KEY_BASE=${SECRET_KEY_BASE}
ENV VISION_HOST=${VISION_HOST}
ENV VISION_USERNAME=${VISION_USERNAME}
ENV VISION_PASSWORD=${VISION_PASSWORD}


RUN mix do local.hex --force, local.rebar --force

ENV MIX_ENV=prod
RUN mix deps.get && \
	npm install --prefix assets && \
	npm run deploy --prefix assets && \
	mix phx.digest && \
	mix release

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
