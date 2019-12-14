defmodule Jarvis.Accounts.Invitation do
  @moduledoc """
  Database module for the entity invitation.
  """
  use Ecto.Schema
  import Ecto.Changeset

  schema "invitations" do
    belongs_to :host, Jarvis.Accounts.User, references: :id
    belongs_to :invitee, Jarvis.Accounts.User, references: :id
    belongs_to :usergroup, Jarvis.Accounts.UserGroup
    field :invitee_email, :string

    timestamps()
  end

  @doc false
  def changeset(invitation, attrs) do
    invitation
    |> cast(attrs, [:invitee_email])
    |> validate_required([:invitee_email])
  end
end
