# jARVIS

To start your Phoenix server:

  * Install dependencies with `mix deps.get`
  * Create and migrate your database with `mix ecto.setup`
  * Install Node.js dependencies with `cd assets && npm install`
  * Start Phoenix endpoint with `mix phx.server`

Now you can visit [`localhost:4000`](http://localhost:4000) from your browser.

## Building

  1. npm run deploy --prefix assets && MIX_ENV=prod REPLACE_OS_VARS=true mix do phx.digest, release --env=prod
  1. docker build --build-arg JARVIS_VERSION=0.7.0 -t jarvis:0.7.0 .

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
