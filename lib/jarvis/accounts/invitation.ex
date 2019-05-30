defmodule Jarvis.Accounts.Invitation do
  use Ecto.Schema
  import Ecto.Changeset

  schema "invitations" do
    field :host_id, :id
    field :invitee_id, :id
    field :usergroup_id, :id

    timestamps()
  end

  @doc false
  def changeset(invitation, attrs) do
    invitation
    |> cast(attrs, [])
    |> validate_required([])
  end
end
