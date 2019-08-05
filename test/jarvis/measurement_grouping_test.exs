defmodule Jarvis.MeasurementGroupingTest do
  use ExUnit.Case

  alias Jarvis.MeasurementGrouping
  alias Jarvis.Sensors.Measurement

  test "group measurements by one description" do
    m1 = %Measurement{description: "temperature", value: 29.7}
    m2 = %Measurement{description: "temperature", value: 33.7}
    m_list = [m1, m2]
    grouped_m = MeasurementGrouping.group_by_description(m_list)

    assert length(Map.get(grouped_m, "temperature")) == 2
    [head | _tail] = Map.get(grouped_m, "temperature")
    assert head.description == m1.description
  end

  test "group measurements by two descriptions" do
    m1 = %Measurement{description: "temperature", value: 29.7}
    m2 = %Measurement{description: "movement_detected", value: 1}
    m_list = [m1, m2]
    grouped_m = MeasurementGrouping.group_by_description(m_list)

    assert length(Map.get(grouped_m, "temperature")) == 1
    assert length(Map.get(grouped_m, "movement_detected")) == 1
  end


end
