defmodule JarvisWeb.MeasurementChannel do
  use JarvisWeb, :channel

  alias Jarvis.Sensors
  alias JarvisWeb.MeasurementView

  def join("measurement", _auth_msg, socket) do
    measurements = list_measurements_since_datetime(nil)
    {:ok, %{"measurements" => measurements}, socket}
  end

  #def handle_in(_topic, _message, socket) do
  #  {:reply, :ok, socket}
  #end

  defp list_measurements_since_datetime(_datetime) do
    measurements = Sensors.list_measurements()
    MeasurementView.render("index.json", %{measurements: measurements})
  end
end
