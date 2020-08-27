![jARVIS](https://raw.githubusercontent.com/corka149/jarvis/master/assets/static/images/logo_jarvis_small.png)

> Portal for managing household (like housekeeping book).

![Elixir CI](https://github.com/corka149/jarvis/workflows/Elixir%20CI/badge.svg)

## Getting jARVIS

The docker way:
```
docker pull corka149/jarvis
```

## Version history

1. Version is the implementation of the the shopping list and user + user groups.
2. Version targets the connecting of sensor devices and measuring for monitoring the flat/house.
3. Version: 
    1. Marks the end of any work targeting smart home. In this version frontend and backend should be separated.
    2. Added finance domain
4. Version is the comeback of jARVIS as multipage application.

## Getting started

To start your dev server:

  * Install dependencies with `pip3 install -r requirements-dev.txt`
  * Run start_db.sh
  * Start flask with ``

Now you can visit [`localhost:4000`](http://localhost:4000) from your browser.

## Developing

Lifecycle for endpoints:
    
    * Routes are defined in views
    * Route parameters are recevied as funtion parameter
    * View models are created
    * Route parameters are forwarded to view models
    * At the end of a route methode the view model is tranformed to a dict

## Building

Just run `python3 docker.py`. It will take care of everything for you. :)

## Configuration

Important environment variables for prod release:

 * HOST - used by Phoenix for URL creation
 * PORT - on which jARVIS should listen
 * SECRET_KEY_BASE - encryption base for cookies
 * DB_USERNAME - username for access to database
 * DB_PASSWORD - password for access to database
 * DB_NAME - name of the selected database
 * DB_HOST - host of database
 * GITHUB_CLIENT_ID - oauth with github
 * GITHUB_CLIENT_SECRET - oauth with github
 * GITHUB_CALLBACK_PATH_PREFIX - will be added to callback url (useful for ingress)

## Important notes

Execute the following as often as possible and fix what you can:

 * `mix format` - formats code
 * `tox` - for ExUnit tests
 * `pylint src` - for type checking
 * `mypy src` - for linting
