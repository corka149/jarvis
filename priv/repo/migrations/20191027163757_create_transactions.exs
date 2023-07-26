defmodule Jarvis.Repo.Migrations.CreateTransactions do
  use Ecto.Migration

  def change do
    create table(:transactions) do
      add :description, :string
      add :value, :float
      add :recurring, :boolean, default: false, null: false
      add :executed_on, :naive_datetime

      timestamps()
    end
  end
end
