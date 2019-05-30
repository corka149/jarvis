defmodule Jarvis.Repo.Migrations.UserUsergroupsMapping do
  use Ecto.Migration

  def change do
    create table(:users_usergroups) do
      add :user_id, references(:users, on_delete: :delete_all)
      add :user_group_id, references(:usergroups, on_delete: :delete_all)
    end

    create index(:users_usergroups, [:user_id])
    create index(:users_usergroups, [:user_group_id])
  end
end
