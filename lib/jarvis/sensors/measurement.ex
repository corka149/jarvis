defmodule Jarvis.Sensors.Measurement do
  use Ecto.Schema
  import Ecto.Changeset

  schema "measurements" do
    field :description, :string
    field :value, :float
    belongs_to :device, Jarvis.Sensors.Device

    timestamps()
  end

  @doc false
  def changeset(measurement, attrs) do
    measurement
    |> cast(attrs, [:description, :value])
    |> validate_required([:description, :value, :device_id])
  end
end
