defmodule JarvisWeb.ItemLive do
  use Phoenix.LiveView

  def mount(_params, _session, socket) do
    temperature = 30
    {:ok, assign(socket, :temperature, temperature)}
  end
end
