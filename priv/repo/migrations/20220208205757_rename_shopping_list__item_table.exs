defmodule Jarvis.Repo.Migrations.RenameShoppingListItemTable do
  use Ecto.Migration

  def change do
    rename table("items"), to: table("products")
  end
end
