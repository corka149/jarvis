defmodule Jarvis.Sensors.Device do
  @moduledoc """
  Database module for the entity device.
  """
  use Ecto.Schema
  import Ecto.Changeset

  schema "devices" do
    field :location, :string
    field :name, :string
    field :external_id, :binary_id
    has_many :measurements, Jarvis.Sensors.Measurement

    timestamps()
  end

  @doc false
  def changeset(device, attrs) do
    device
    |> cast(attrs, [:name, :location, :external_id])
    |> validate_required([:name, :location, :external_id])
  end
end
