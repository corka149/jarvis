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
    case get_device?(measurement_params) do
      {:ok, device}     -> create_and_201(conn, measurement_params, device)
      {:error, reason}  -> conn |> bad_request(reason)
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

  # Creates a measurement entry and returns the json
  defp create_and_201(conn, measurement_params, device) do
    with {:ok, %Measurement{} = measurement} <- Sensors.create_measurement(measurement_params, device) do
      conn
      |> put_status(:created)
      |> put_resp_header("location", Routes.measurement_path(conn, :show, measurement))
      |> render("show.json", measurement: measurement)
    end
  end

  # Checks if device id is available and return the referred device when id is available
  defp get_device?(measurement_params) do
    case Map.get(measurement_params, "device_id") do
      nil       -> {:error, "No device id found."}
      device_id -> Sensors.get_device(device_id)
    end
  end

  defp bad_request(conn, reason) do
    conn |> put_status(400) |> render("error.json", error: reason)
  end
end
