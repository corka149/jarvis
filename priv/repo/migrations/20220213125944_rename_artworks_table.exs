defmodule Jarvis.Repo.Migrations.RenameArtworksTable do
  use Ecto.Migration

  def change do
    rename(table("artworks"), to: table("items"))
  end
end
