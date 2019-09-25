import Config

config :jarvis, JarvisWeb.Endpoint,
  http: [:inet6, port: System.fetch_env!("PORT")],
  url: [host: System.fetch_env!("HOST"), port: System.fetch_env!("PORT")], # This is critical for ensuring web-sockets properly authorize.
  cache_static_manifest: "priv/static/cache_manifest.json",
  server: true,
  root: ".",
  version: Application.spec(:jarvis, :vsn)

config :logger, level: :info

config :phoenix, :serve_endpoints, true

config :jarvis, JarvisWeb.Endpoint,
  secret_key_base: System.fetch_env!("SECRET_KEY_BASE")

config :jarvis, Jarvis.Repo,
  username: System.fetch_env!("DB_USERNAME"),
  password: System.fetch_env!("DB_PASSWORD"),
  database: System.fetch_env!("DB_NAME"),
  hostname: System.fetch_env!("DB_HOST"),
  pool_size: 15

config :jarvis, Jarvis.ShoppingLists.Vision,
  host: System.fetch_env!("VISION_HOST"),
  username: System.fetch_env!("VISION_USERNAME"),
  password: System.fetch_env!("VISION_PASSWORD")

config :ueberauth, Ueberauth.Strategy.Github.OAuth,
  client_id: System.fetch_env!("GITHUB_CLIENT_ID"),
  client_secret: System.fetch_env!("GITHUB_CLIENT_SECRET")
