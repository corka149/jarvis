FROM elixir
LABEL maintainer="corka149 <corka149@mailbox.org>"

ADD ./_build/prod/rel/jarvis/releases/0.5.0/jarvis.tar.gz /app

ENTRYPOINT ["app/bin/jarvis"]
CMD ["foreground"]