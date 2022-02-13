defmodule Jarvis.ShoppingLists.ShoppingList do
  @moduledoc """
  Database module for the entity shopping list.
  """
  use Ecto.Schema
  import Ecto.Changeset

  schema "shoppinglists" do
    field :done, :boolean, default: false
    field :planned_for, :date
    field :creator, :id
    belongs_to :usergroup, Jarvis.Accounts.UserGroup, foreign_key: :belongs_to
    has_many :products, Jarvis.ShoppingLists.Product

    timestamps()
  end

  @doc false
  def changeset(shopping_list, attrs) do
    shopping_list
    |> cast(attrs, [:done, :planned_for, :belongs_to])
    |> validate_required([:done, :planned_for, :belongs_to])
  end
end
