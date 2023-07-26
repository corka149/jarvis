defmodule Jarvis.Repo.Migrations.LinkDeviceToMeasurements do
  use Ecto.Migration

  def change do
    alter table(:measurements) do
      add :device_id, references(:devices)
    end
  end
end
