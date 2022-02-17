defmodule Jarvis.Accounts.UserGroup do
  @moduledoc """
  Database module for the entity user_group.
  """
  use Ecto.Schema
  import Ecto.Changeset

  schema "usergroups" do
    field :name, :string
    belongs_to :user, Jarvis.Accounts.User
    many_to_many :has_member, Jarvis.Accounts.User, join_through: "users_usergroups"
    has_many :invitations, Jarvis.Accounts.Invitation, foreign_key: :usergroup_id

    # ShoppingLists
    has_many :shoppinglists, Jarvis.ShoppingLists.ShoppingList, foreign_key: :belongs_to

    # Inventory
    has_many :places, Jarvis.Inventory.Place, foreign_key: :owned_by

    timestamps()
  end

  @doc false
  def changeset(user_group, attrs) do
    user_group
    |> cast(attrs, [:name])
    |> validate_required([:name])
  end
end
