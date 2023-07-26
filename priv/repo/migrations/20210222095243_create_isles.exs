defmodule Jarvis.Repo.Migrations.CreateIsles do
  use Ecto.Migration

  def change do
    create table(:isles) do
      add :name, :string

      timestamps()
    end
  end
end
