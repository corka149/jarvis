
launch-database:
	docker-compose -p jarvis_backend -f __ops__/dev/docker-compose.yml up -d
	mix ecto.migrate
	mix run scripts/create_user.exs

dev: launch-database
	iex -S mix phx.server

check: launch-database
	mix format
	mix test
	mix dialyzer
	mix credo --strict
