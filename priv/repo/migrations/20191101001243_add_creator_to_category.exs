defmodule Jarvis.Repo.Migrations.AddCreatorToCategory do
  use Ecto.Migration

  def change do
    alter table(:categories) do
      add :created_by, references(:users)
    end
  end
end
