defmodule Jarvis.Accounts.User do
  @moduledoc """
  Database module for the entity user.
  """
  use Ecto.Schema
  import Ecto.Changeset

  schema "users" do
    field :email, :string
    field :name, :string
    field :provider, :string
    field :token, :string
    has_many :usergroups, Jarvis.Accounts.UserGroup
    many_to_many :member_of, Jarvis.Accounts.UserGroup, join_through: "users_usergroups"
    has_many :created_invitations, Jarvis.Accounts.Invitation, foreign_key: :host_id
    has_many :received_invitations, Jarvis.Accounts.Invitation, foreign_key: :invitee_id
    field :default_language, :string
    has_many :transactions, Jarvis.Finances.Transaction, foreign_key: :created_by
    has_many :categories, Jarvis.Finances.Category, foreign_key: :created_by

    timestamps()
  end

  @doc false
  def changeset(user, attrs) do
    user
    |> cast(attrs, [:name, :email, :provider, :token, :default_language])
    |> validate_format(:email, email_validation())
    |> validate_required([:name, :email, :provider, :token])
    |> unique_constraint(:email)
  end

  def email_validation do
    ~r/^[_a-z0-9-]+(.[a-z0-9-]+)@[a-z0-9-]+(.[a-z0-9-]+)*(.[a-z]{2,4})$/
  end
end
