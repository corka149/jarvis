export PORT=4000

export HOST=localhost

export DB_PASSWORD=secret
export DB_USERNAME=postgres
export DB_NAME=jarvis
export DB_HOST=localhost

export GITHUB_CLIENT_ID=
export GITHUB_CLIENT_SECRET=

export SECRET_KEY_BASE=$(elixir -e ":crypto.strong_rand_bytes(48) |> Base.encode64 |> IO.puts")
