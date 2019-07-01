defmodule JarvisWeb.DeviceController do
  use JarvisWeb, :controller

  alias Jarvis.Sensors
  alias Jarvis.Sensors.Device

  action_fallback JarvisWeb.FallbackController

  def index(conn, _params) do
    devices = Sensors.list_devices()
    render(conn, "index.json", devices: devices)
  end

  def create(conn, %{"device" => device_params}) do
    with {:ok, %Device{} = device} <- Sensors.create_device(device_params) do
      conn
      |> put_status(:created)
      |> put_resp_header("location", Routes.device_path(conn, :show, device))
      |> render("show.json", device: device)
    end
  end

  def show(conn, %{"id" => id}) do
    device = Sensors.get_device!(id)
    render(conn, "show.json", device: device)
  end

  def update(conn, %{"id" => id, "device" => device_params}) do
    device = Sensors.get_device!(id)

    with {:ok, %Device{} = device} <- Sensors.update_device(device, device_params) do
      render(conn, "show.json", device: device)
    end
  end

  def delete(conn, %{"id" => id}) do
    device = Sensors.get_device!(id)

    with {:ok, %Device{}} <- Sensors.delete_device(device) do
      send_resp(conn, :no_content, "")
    end
  end
end
