defmodule Jarvis.Repo.Migrations.DeleteFinanceTables do
  use Ecto.Migration

  def change do
    drop table(:transactions)
    drop table(:categories)
  end
end
