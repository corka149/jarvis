defmodule Jarvis.Finances.Category do
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
    |> cast(attrs, [:name])
    |> validate_required([:name])
  end
end
