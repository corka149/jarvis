defmodule JarvisWeb.UserSocket do
  use Phoenix.Socket


  channel "measurement", JarvisWeb.MeasurementChannel


  def connect(_params, socket, _connect_info) do
    {:ok, socket}
  end

  def id(_socket), do: nil
end
