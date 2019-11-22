defmodule Jarvis.Finances.Transaction do
  @moduledoc """
  Database module for the entity transaction.
  """
  use Ecto.Schema
  import Ecto.Changeset

  schema "transactions" do
    field :description, :string
    field :executed_on, :naive_datetime
    field :recurring, :boolean, default: false
    field :value, :float
    belongs_to :category, Jarvis.Finances.Category
    belongs_to :creator, Jarvis.Accounts.User, foreign_key: :created_by

    timestamps()
  end

  @doc false
  def changeset(transaction, attrs) do
    transaction
    |> cast(attrs, [:description, :value, :recurring, :executed_on, :created_by, :category_id])
    |> validate_required([
      :description,
      :value,
      :recurring,
      :executed_on,
      :created_by,
      :category_id
    ])
  end
end
