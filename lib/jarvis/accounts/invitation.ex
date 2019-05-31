defmodule Jarvis.Accounts.Invitation do
  use Ecto.Schema
  import Ecto.Changeset

  schema "invitations" do
    belongs_to :host, Jarvis.Accounts.User, references: :created_invatations
    belongs_to :invitee, Jarvis.Accounts.User, references: :received_invatations
    belongs_to :usergroup, Jarvis.Accounts.UserGroup
    field :invitee_name, :string

    timestamps()
  end

  @doc false
  def changeset(invitation, attrs) do
    invitation
    |> cast(attrs, [:invitee_name])
    |> validate_required([:invitee_name])
  end
end
