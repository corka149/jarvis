import Config

# WEB
config :jarvis, JarvisWeb.Endpoint,
  # HTTP
  http: [:inet6, port: System.fetch_env!("HTTP_PORT")],
  # HTTPS
  ## https: [
  ##  :inet6,
  ##  port: System.fetch_env!("HTTPS_PORT"),
  ##  cipher_suite: :strong,
  ##  keyfile: System.get_env("SSL_KEY_PATH"),
  ##  certfile: System.get_env("SSL_CERT_PATH")
  ## ],
  # OTHER
  server: true,
  root: ".",
  url: [host: System.fetch_env!("HOST"), port: System.fetch_env!("HTTP_PORT")],
  version: Application.spec(:jarvis, :vsn),
  secret_key_base: System.fetch_env!("SECRET_KEY_BASE")

# LOGGING
config :logger, level: :warn

config :phoenix, :serve_endpoints, true

# DATABASE
config :jarvis, Jarvis.Repo,
  username: System.fetch_env!("DB_USERNAME"),
  password: System.fetch_env!("DB_PASSWORD"),
  database: System.fetch_env!("DB_NAME"),
  hostname: System.fetch_env!("DB_HOST"),
  port: System.fetch_env!("DB_PORT"),
  pool_size: 15
