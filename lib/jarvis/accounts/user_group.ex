defmodule Jarvis.Accounts.UserGroup do
  use Ecto.Schema
  import Ecto.Changeset

  schema "usergroups" do
    field :name, :string
    belongs_to :user, Jarvis.Accounts.User
    has_many :shoppinglists, Jarvis.ShoppingLists.ShoppingList, foreign_key: :belongs_to
    many_to_many :has_member, Jarvis.Accounts.User, join_through: "users_usergroups"

    timestamps()
  end

  @doc false
  def changeset(user_group, attrs) do
    user_group
    |> cast(attrs, [:name])
    |> validate_required([:name])
  end
end
