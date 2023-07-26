defmodule Jarvis.Repo.Migrations.AddUserIdToUsergroups do
  use Ecto.Migration

  def change do
    alter table(:usergroups) do
      add :user_id, references(:users)
    end
  end
end
