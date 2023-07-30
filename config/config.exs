# This file is responsible for configuring your application
# and its dependencies with the aid of the Mix.Config module.
#
# This configuration file is loaded before any dependency and
# is restricted to this project.

# General application configuration
import Config

config :jarvis,
  ecto_repos: [Jarvis.Repo]

# Configures the endpoint
config :jarvis, JarvisWeb.Endpoint,
  url: [host: "localhost"],
  secret_key_base: "/ogYigSCve4T4V40gzDmNpQaGtg5eIy3BnBS2JpFv4wT35cwbFTBh5AcvWUw9Fdt",
  render_errors: [view: JarvisWeb.ErrorHTML, accepts: ~w(html json)],
  pubsub_server: Jarvis.PubSub,
  default_locale: "en",
  locales: ~w(en de),
  live_view: [signing_salt: "7aYD7+wKzIBHucQ6j5go9EDxQC9O7YYk"]

# Configures Elixir's Logger
config :logger, :console,
  format: "$time $metadata[$level] $message\n",
  metadata: [:request_id]

# Use Jason for JSON parsing in Phoenix
config :phoenix, :json_library, Jason

# Configure esbuild (the version is required)
config :esbuild,
  version: "0.12.18",
  default: [
    args: ~w(js/app.js --bundle --target=es2016 --outdir=../priv/static/assets),
    cd: Path.expand("../assets", __DIR__),
    env: %{"NODE_PATH" => Path.expand("../deps", __DIR__)}
  ]

# Import environment specific config. This must remain at the bottom
# of this file so it overrides the configuration defined above.
import_config "#{Mix.env()}.exs"
