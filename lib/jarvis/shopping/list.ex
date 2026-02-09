defmodule Jarvis.Shopping.List do
  use Ecto.Schema
  import Ecto.Changeset

  schema "shopping_lists" do
    field :title, :string
    field :status, Ecto.Enum, values: [:open, :done, :deleted], default: :open
    field :purchase_at, :date

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(list, attrs) do
    list
    |> cast(attrs, [:title, :status, :purchase_at])
    |> validate_required([:title, :status, :purchase_at])
  end
end
