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
      value: measurement.value,
      inserted_at: measurement.inserted_at
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

    #######################################
   ############# For chart view ##########
  #######################################
  def render("chart_list.json", %{measurements: measurements}) do
    %{
      data: render_many(measurements, MeasurementView, "chart_single.json")
    }
  end

  def render("chart_single.json", %{measurement: measurement}) do
    %{
      description: measurement.description,
      location: measurement.device.location,
      dataset: %{
        y: measurement.inserted_at,
        x: measurement.value
      }
    }
  end
end
