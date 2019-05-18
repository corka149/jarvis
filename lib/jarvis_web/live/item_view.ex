defmodule JarvisWeb.ItemLive do
  use Phoenix.LiveView
  alias JarvisWeb.ItemView

  # Will be call first
  def mount(_session, socket) do
    {:ok, assign(socket, :val, 0)}
  end

  def render(assigns) do
    ItemView.render("index.html", assigns)
  end

  def handle_event("inc", _, socket) do
    {:noreply, update(socket, :val, &(&1 + 1))}
  end

  def handle_event("dec", _, socket) do
    {:noreply, update(socket, :val, &(&1 - 1))}
  end
end
