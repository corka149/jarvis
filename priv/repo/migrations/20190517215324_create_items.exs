defmodule Jarvis.Repo.Migrations.CreateItems do
  use Ecto.Migration

  def change do
    create table(:items) do
      add :name, :string
      add :amount, :integer
      add :shopping_list_id, references(:shoppinglists, on_delete: :nothing)

      timestamps()
    end

    create index(:items, [:shopping_list_id])
  end
end
