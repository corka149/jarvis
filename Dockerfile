FROM elixir
LABEL maintainer="corka149 <corka149@mailbox.org>"

ARG JARVIS_VERSION

ADD ./_build/prod/rel/jarvis/releases/$JARVIS_VERSION/jarvis.tar.gz /app

ENTRYPOINT ["app/bin/jarvis"]
CMD ["foreground"]