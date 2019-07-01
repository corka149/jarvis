defmodule JarvisWeb.MeasurementView do
  use JarvisWeb, :view
  alias JarvisWeb.MeasurementView

  def render("index.json", %{measurements: measurements}) do
    %{data: render_many(measurements, MeasurementView, "measurement.json")}
  end

  def render("show.json", %{measurement: measurement}) do
    %{data: render_one(measurement, MeasurementView, "measurement.json")}
  end

  def render("measurement.json", %{measurement: measurement}) do
    %{id: measurement.id,
      describition: measurement.describition,
      value: measurement.value}
  end
end
