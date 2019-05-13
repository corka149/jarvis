defmodule Jarvis.ShoppingLists.ShoppingList do
  use Ecto.Schema
  import Ecto.Changeset

  schema "shoppinglists" do
    field :done, :boolean, default: false
    field :planned_for, :date
    field :creator, :id
    field :belongs_to, :id

    timestamps()
  end

  @doc false
  def changeset(shopping_list, attrs) do
    shopping_list
    |> cast(attrs, [:done, :planned_for])
    |> validate_required([:done, :planned_for])
  end
end
