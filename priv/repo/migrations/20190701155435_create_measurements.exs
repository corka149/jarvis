defmodule Jarvis.Repo.Migrations.CreateMeasurements do
  use Ecto.Migration

  def change do
    create table(:measurements) do
      add :description, :string
      add :value, :float

      timestamps()
    end
  end
end
