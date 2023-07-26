defmodule Jarvis.Repo.Migrations.CreateArtworks do
  use Ecto.Migration

  def change do
    create table(:artworks) do
      add :name, :string

      timestamps()
    end
  end
end
