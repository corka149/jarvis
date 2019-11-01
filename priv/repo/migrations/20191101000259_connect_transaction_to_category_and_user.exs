defmodule Jarvis.Repo.Migrations.ConnectTransactionToCategory do
  use Ecto.Migration

  def change do
    alter table(:transactions) do
      add :category_id, references(:categories)
      add :created_by, references(:users)
    end
  end
end
