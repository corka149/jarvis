defmodule Jarvis.ShoppingLists.Product do
  @moduledoc """
  Database module for the entity product.
  """
  use Ecto.Schema
  import Ecto.Changeset

  schema "products" do
    field :amount, :integer
    field :name, :string
    belongs_to :shopping_list, Jarvis.ShoppingLists.ShoppingList

    timestamps()
  end

  @doc false
  def changeset(product, attrs) do
    product
    |> cast(attrs, [:name, :amount, :shopping_list_id])
    |> validate_required([:name, :amount, :shopping_list_id])
  end
end
