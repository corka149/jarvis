defmodule Jarvis.Repo.Migrations.AddApiTokenToUser do
  use Ecto.Migration

  def change do
    alter table(:users) do
      add :api_token, :binary_id
    end
  end
end
