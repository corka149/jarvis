defmodule Jarvis.Sensors.Measurement do
  use Ecto.Schema
  import Ecto.Changeset

  schema "measurements" do
    field :describition, :string
    field :value, :float

    timestamps()
  end

  @doc false
  def changeset(measurement, attrs) do
    measurement
    |> cast(attrs, [:describition, :value])
    |> validate_required([:describition, :value])
  end
end
