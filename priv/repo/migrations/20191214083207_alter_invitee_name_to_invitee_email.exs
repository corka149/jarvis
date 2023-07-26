defmodule Jarvis.Repo.Migrations.AlterInviteeNameToInviteeEmail do
  use Ecto.Migration

  def change do
    rename table("invitations"), :invitee_name, to: :invitee_email
  end
end
