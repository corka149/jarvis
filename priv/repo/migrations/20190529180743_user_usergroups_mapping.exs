defmodule Jarvis.Repo.Migrations.UserUsergroupsMapping do
  use Ecto.Migration

  def change do
    create table(:users_usergroups) do
      add :user, references(:users, on_delete: :nothing)
      add :usergroup, references(:usergroups, on_delete: :nothing)
    end

    create index(:users_usergroups, [:user])
    create index(:users_usergroups, [:usergroup])
  end
end
