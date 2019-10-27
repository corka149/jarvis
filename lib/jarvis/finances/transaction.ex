defmodule Jarvis.Finances.Transaction do
  use Ecto.Schema
  import Ecto.Changeset

  schema "transactions" do
    field :description, :string
    field :executed_on, :naive_datetime
    field :recurring, :boolean, default: false
    field :value, :float

    timestamps()
  end

  @doc false
  def changeset(transaction, attrs) do
    transaction
    |> cast(attrs, [:description, :value, :recurring, :executed_on])
    |> validate_required([:description, :value, :recurring, :executed_on])
  end
end
