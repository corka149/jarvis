defmodule Jarvis.Finances.Category do
  @moduledoc """
  Database module for the entity category.
  """
  use Ecto.Schema
  import Ecto.Changeset

  schema "categories" do
    field :name, :string
    has_many :transactions, Jarvis.Finances.Transaction
    belongs_to :creator, Jarvis.Accounts.User, foreign_key: :created_by

    timestamps()
  end

  @doc false
  def changeset(category, attrs) do
    category
    |> cast(attrs, [:name, :created_by])
    |> validate_required([:name, :created_by])
  end
end
