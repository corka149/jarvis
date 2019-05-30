defmodule Jarvis.Repo.Migrations.CreateInvitations do
  use Ecto.Migration

  def change do
    create table(:invitations) do
      add :host_id, references(:users, on_delete: :delete_all)
      add :invitee_id, references(:users, on_delete: :delete_all)
      add :usergroup_id, references(:usergroups, on_delete: :delete_all)
      add :invitee_name, :string

      timestamps()
    end

    create index(:invitations, [:host_id])
    create index(:invitations, [:invitee_id])
    create index(:invitations, [:usergroup_id])
  end
end
