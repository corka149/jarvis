defmodule Jarvis.Repo.Migrations.AddLangToUser do
  use Ecto.Migration

  def change do
    alter table(:users) do
      add :default_language, :string, default: "en"
    end
  end
end
