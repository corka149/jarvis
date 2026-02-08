defmodule Jarvis.Shopping.Item do
  use Ecto.Schema
  import Ecto.Changeset

  schema "shopping_items" do
    field :name, :string
    field :amount, :float
    field :list_id, :id

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(item, attrs) do
    item
    |> cast(attrs, [:name, :amount])
    |> validate_required([:name, :amount])
  end
end
