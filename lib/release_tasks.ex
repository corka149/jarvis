defmodule Jarvis.Tasks do
  def migrate do
    {:ok, _} = Application.ensure_all_started(:jarvis)

    path = Application.app_dir(:jarvis, "priv/repo/migrations")
    Ecto.Migrator.run(Jarvis.Repo, path, :up, all: true)
  end
end
