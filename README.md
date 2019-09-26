# jARVIS

Portal for managing household (like housekeeping book) and smart home.

## Version history

  1. Version is the implementation of the the shopping list and user + user groups.
  2. Version targets the connecting of sensor devices and measuring for monitoring the flat/house.


To start your Phoenix server:

  * Install dependencies with `mix deps.get`
  * Run startPostgres.sh
  * Create and migrate your database with `mix ecto.setup`
  * Install Node.js dependencies with `cd assets && npm install`
  * Start Phoenix endpoint with `mix phx.server`

Now you can visit [`localhost:4000`](http://localhost:4000) from your browser.

## Building

Just run `mix docker`. It will take care everything for you. :)

## Configuration

Important environment variables for prod release:

 * PORT
 * SECRET_KEY_BASE
 * DB_USERNAME
 * DB_PASSWORD
 * DB_NAME
 * DB_HOST
 * GITHUB_CLIENT_ID
 * GITHUB_CLIENT_SECRET
 * VISION_HOST
 * VISION_USERNAME
 * VISION_PASSWORD

## Important notes

Execute the following as often as possible and fix what you can:

 * `mix format` - formats code
 * `mix test` - for ExUnit tests
 * `mix dialyzer` - for type checking
 * `mix credo` - for linting
