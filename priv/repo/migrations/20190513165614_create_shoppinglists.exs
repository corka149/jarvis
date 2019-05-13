defmodule Jarvis.Repo.Migrations.CreateShoppinglists do
  use Ecto.Migration

  def change do
    create table(:shoppinglists) do
      add :done, :boolean, default: false, null: false
      add :planned_for, :date
      add :creator, references(:users, on_delete: :nothing)
      add :belongs_to, references(:usergroups, on_delete: :nothing)

      timestamps()
    end

    create index(:shoppinglists, [:creator])
    create index(:shoppinglists, [:belongs_to])
  end
end
