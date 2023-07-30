
launch-database:
	docker-compose -p jarvis_backend -f __ops__/dev/docker-compose.yml up -d postgres
	mix ecto.migrate
	mix run scripts/create_user.exs

dev: launch-database
	iex -S mix phx.server

check: launch-database
	mix format
	mix test --warnings-as-errors
	mix dialyzer
	mix credo --strict


install:
	MIX_ENV=prod mix deps.get --only prod
	MIX_ENV=prod mix compile --warnings-as-errors
	npm install --prefix ./assets
	npm run deploy --prefix ./assets
	MIX_ENV=prod mix phx.digest
	MIX_ENV=prod mix release
