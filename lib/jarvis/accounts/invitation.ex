defmodule Jarvis.Accounts.Invitation do
  use Ecto.Schema
  import Ecto.Changeset

  schema "invitations" do
    belongs_to :host, Jarvis.Accounts.User
    belongs_to :invitee, Jarvis.Accounts.User
    belongs_to :usergroup, Jarvis.Accounts.UserGroup
    field :invitee_name, :string

    timestamps()
  end

  @doc false
  def changeset(invitation, attrs) do
    invitation
    |> cast(attrs, [])
    |> validate_required([])
  end
end
