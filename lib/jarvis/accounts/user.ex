defmodule Jarvis.Accounts.User do
  use Ecto.Schema
  import Ecto.Changeset

  schema "users" do
    field :email, :string
    field :name, :string
    field :provider, :string
    field :token, :string
    has_many :usergroups, Jarvis.Accounts.UserGroup
    many_to_many :member_of, Jarvis.Accounts.UserGroup, join_through: "users_usergroups"

    timestamps()
  end

  @doc false
  def changeset(user, attrs) do
    user
    |> cast(attrs, [:name, :email, :provider, :token])
    |> validate_required([:name, :email, :provider, :token])
  end
end
