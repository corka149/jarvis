defmodule Jarvis.Util.MeasurementGrouping do
  @moduledoc """
  Module for grouping and re-ordering measurements.
  """

  alias Jarvis.Sensors.Device
  alias Jarvis.Sensors.Measurement

  def group_measurements(measurements) do
    do_grouping(measurements, %{})
  end

  defp do_grouping([], accumulator_map), do: accumulator_map

  defp do_grouping([%Measurement{} = measurement | tail], accumulator_map) do
    accumulator_map = put_in_path(measurement, accumulator_map)
    do_grouping(tail, accumulator_map)
  end

  defp put_in_path(
         %Measurement{description: description, device: %Device{location: location}} =
           measurement,
         accumulator_map
       ) do
    case get_in(accumulator_map, [description, location]) do
      nil ->
        accumulator_map = put_in(accumulator_map, [description], %{location => []})
        put_in(accumulator_map, [description, location], [measurement])

      _ ->
        update_in(accumulator_map, [description, location], &[measurement | &1])
    end
  end
end
