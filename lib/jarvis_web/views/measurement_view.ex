defmodule JarvisWeb.MeasurementView do
  use JarvisWeb, :view
  alias JarvisWeb.MeasurementView
  alias JarvisWeb.DeviceView

  def render("index.json", %{measurements: measurements}) do
    %{
      data: render_many(measurements, MeasurementView, "measurement.json")
    }
  end

  def render("show.json", %{measurement: measurement}) do
    %{
      data: render_one(measurement, MeasurementView,"measurement_with_device.json")
    }
  end

  def render("error.json", %{error: reason}) do
    %{
      scope: "measurements",
      error: reason
    }
  end

  def render("measurement.json", %{measurement: measurement}) do
    %{
      id: measurement.id,
      description: measurement.description,
      value: measurement.value
    }
  end

  def render("measurement_with_device.json", %{measurement: measurement}) do
    %{
      id: measurement.id,
      description: measurement.description,
      value: measurement.value,
      device: render_one(measurement.device, DeviceView, "device.json")
    }
  end
end
