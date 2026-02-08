defmodule Jarvis.Repo.Migrations.CreateShoppingItems do
  use Ecto.Migration

  def change do
    create table(:shopping_items) do
      add :name, :string, null: false
      add :amount, :float, null: false
      add :list_id, references(:shopping_lists, on_delete: :nothing), null: false

      timestamps(type: :utc_datetime)
    end

    create index(:shopping_items, [:list_id])
  end
end
