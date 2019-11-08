defmodule Jarvis.Repo.Migrations.AddedPasswordToUser do
  use Ecto.Migration

  def change do
    alter table(:users) do
      add :password, :string
      add :password_hash, :string
    end
  end
end
