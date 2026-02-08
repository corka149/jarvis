defmodule Jarvis.Repo.Migrations.CreateShoppingLists do
  use Ecto.Migration

  def change do
    create table(:shopping_lists) do
      add :title, :string, null: false
      add :status, :string, null: false
      add :purchase_at, :date, null: false

      timestamps(type: :utc_datetime)
    end
  end
end
