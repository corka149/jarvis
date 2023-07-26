defmodule Jarvis.Repo.Migrations.AddReferencesForIsles do
  use Ecto.Migration

  def change do
    alter table(:isles) do
      add :owned_by, references(:usergroups), null: false
    end

    alter table(:artworks) do
      add :belongs_to, references(:isles), null: false
    end
  end
end
