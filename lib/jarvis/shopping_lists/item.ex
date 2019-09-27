defmodule Jarvis.ShoppingLists.Item do
  @moduledoc """
  Database module for the entity item.
  """
  use Ecto.Schema
  import Ecto.Changeset

  schema "items" do
    field :amount, :integer
    field :name, :string
    belongs_to :shopping_list, Jarvis.ShoppingLists.ShoppingList

    timestamps()
  end

  @doc false
  def changeset(item, attrs) do
    item
    |> cast(attrs, [:name, :amount, :shopping_list_id])
    |> validate_required([:name, :amount, :shopping_list_id])
  end
end
