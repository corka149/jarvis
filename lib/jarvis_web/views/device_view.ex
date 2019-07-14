defmodule JarvisWeb.DeviceView do
  use JarvisWeb, :view
  alias JarvisWeb.DeviceView

  def render("index.json", %{devices: devices}) do
    %{
      data: render_many(devices, DeviceView, "device.json")
    }
  end

  def render("show.json", %{device: device}) do
    %{
      data: render_one(device, DeviceView, "device.json")
    }
  end

  def render("error.json", %{error: reason}) do
    %{
      scope: "devices",
      error: reason
    }
  end

  def render("device.json", %{device: device}) do
    %{
      id: device.id,
      name: device.name,
      location: device.location
    }
  end
end
