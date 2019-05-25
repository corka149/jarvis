# jARVIS

To start your Phoenix server:

  * Install dependencies with `mix deps.get`
  * Create and migrate your database with `mix ecto.setup`
  * Install Node.js dependencies with `cd assets && npm install`
  * Start Phoenix endpoint with `mix phx.server`

Now you can visit [`localhost:4000`](http://localhost:4000) from your browser.

## Building

Here is a bunch of links and notes for creating a release version with Distillery

### Links

 * https://hexdocs.pm/distillery/guides/phoenix_walkthrough.html
 * http://sgeos.github.io/phoenix/elixir/erlang/ecto/distillery/postgresql/mysql/2016/09/18/storing-elixir-release-configuration-in-environment-variables-with-distillery.html
 * https://blog.leif.io/deploying-elixir-with-docker-part-2/
 * http://blog.firstiwaslike.com/elixir-deployments-with-distillery-running-ecto-migrations/

### Steps

  1. npm run deploy --prefix assets && MIX_ENV=prod REPLACE_OS_VARS=true mix do phx.digest, release --env=prod
  1. Adjust version number in Dockerfile?
  1. docker build -t jarvis:latest .

## Configuration

Important environment variables for prod release

 * PORT
 * SECRET_KEY_BASE
 * DB_USERNAME
 * DB_PASSWORD
 * DB_NAME
 * DB_HOST
 * AUTH0_DOMAIN
 * AUTH0_CLIENT_ID
 * AUTH0_CLIENT_SECRET
