defmodule Jarvis.MeasurementGrouping do

  alias Jarvis.Sensors.Measurement

  def group_by_description(measurements) do
    do_group_by_description(measurements, %{})
  end

  defp do_group_by_description([], %{} = accumulator_map), do: accumulator_map

  defp do_group_by_description([%Measurement{} = measurement | tail], %{} = accumulator_map) do
    described_measurements = Map.get(accumulator_map, measurement.description, [])
    mapped = Map.put(accumulator_map, measurement.description, [measurement | described_measurements])
    do_group_by_description(tail, mapped)
  end

end
