defmodule Jarvis.Sensors.Device do
  use Ecto.Schema
  import Ecto.Changeset

  schema "devices" do
    field :location, :string
    field :name, :string
    has_many :measurements, Jarvis.Sensors.Measurement

    timestamps()
  end

  @doc false
  def changeset(device, attrs) do
    device
    |> cast(attrs, [:name, :location])
    |> validate_required([:name, :location])
  end
end
