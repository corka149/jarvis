defmodule JarvisWeb.MeasurementController do
  use JarvisWeb, :controller

  alias Jarvis.Sensors
  alias Jarvis.Sensors.Measurement

  action_fallback JarvisWeb.FallbackController

  def index(conn, _params) do
    measurements = Sensors.list_measurements()
    render(conn, "index.json", measurements: measurements)
  end

  def create(conn, %{"measurement" => measurement_params}) do
    with {:ok, %Measurement{} = measurement} <- Sensors.create_measurement(measurement_params) do
      conn
      |> put_status(:created)
      |> put_resp_header("location", Routes.measurement_path(conn, :show, measurement))
      |> render("show.json", measurement: measurement)
    end
  end

  def show(conn, %{"id" => id}) do
    measurement = Sensors.get_measurement!(id)
    render(conn, "show.json", measurement: measurement)
  end

  def update(conn, %{"id" => id, "measurement" => measurement_params}) do
    measurement = Sensors.get_measurement!(id)

    with {:ok, %Measurement{} = measurement} <- Sensors.update_measurement(measurement, measurement_params) do
      render(conn, "show.json", measurement: measurement)
    end
  end

  def delete(conn, %{"id" => id}) do
    measurement = Sensors.get_measurement!(id)

    with {:ok, %Measurement{}} <- Sensors.delete_measurement(measurement) do
      send_resp(conn, :no_content, "")
    end
  end
end