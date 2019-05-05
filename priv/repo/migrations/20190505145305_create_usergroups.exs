defmodule Jarvis.Repo.Migrations.CreateUsergroups do
  use Ecto.Migration

  def change do
    create table(:usergroups) do
      add :name, :string

      timestamps()
    end

  end
end
