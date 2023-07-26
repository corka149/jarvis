defmodule Jarvis.Repo.Migrations.AddExternalIdentifier do
  use Ecto.Migration

  def change do
    alter table(:devices) do
      add :external_id, :binary_id
    end
  end
end
