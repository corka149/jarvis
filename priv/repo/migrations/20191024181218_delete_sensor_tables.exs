defmodule Jarvis.Repo.Migrations.DeleteSensorTables do
  use Ecto.Migration

  def change do
    drop table(:measurements)
    drop table(:devices)
  end
end
