![jARVIS](https://raw.githubusercontent.com/corka149/jarvis/master/assets/static/images/logo_jarvis_small.png)

> Portal for managing household (like housekeeping book).

![Build result](https://travis-ci.org/corka149/jarvis.svg?branch=master)

## Version history

1. Version is the implementation of the the shopping list and user + user groups.
2. Version targets the connecting of sensor devices and measuring for monitoring the flat/house.
3. Version: 
    1. Marks the end of any work targeting smart home. In this version frontend and backend should be separated.
    2. Added finance domain

## Getting start

To start your Phoenix server:

  * Install dependencies with `mix deps.get`
  * Run startPostgres.sh
  * Create and migrate your database with `mix ecto.setup`
  * Install Node.js dependencies with `cd assets && npm install`
  * Start Phoenix endpoint with `mix phx.server`

Now you can visit [`localhost:4000`](http://localhost:4000) from your browser.

## Building

Just run `mix docker`. It will take care of everything for you. :)

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

## Important notes

Execute the following as often as possible and fix what you can:

 * `mix format` - formats code
 * `mix test` - for ExUnit tests
 * `mix dialyzer` - for type checking
 * `mix credo` - for linting
