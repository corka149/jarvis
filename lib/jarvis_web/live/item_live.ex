defmodule JarvisWeb.ItemLive do
  @moduledoc """
  Live "controller" for items
  """

  use Phoenix.LiveView
  use Phoenix.HTML

  alias Jarvis.ShoppingLists
  alias JarvisWeb.ItemView

  @impl true
  def mount(%{"shopping_list_id" => shopping_list_id}, %{"user_id" => _user_id} = _session, socket) do
    shopping_list =  ShoppingLists.get_shopping_list!(shopping_list_id)
    changeset = ShoppingLists.change_item(%ShoppingLists.Item{})

    {:ok, assign(socket, shopping_list: shopping_list) |> assign(changeset: changeset) }
  end

  @doc """
  Renders the static HTML after mounting the session.
  """
  @impl true
  def render(assigns) do
    ItemView.render("index.html", assigns)
  end

  @impl true
  def handle_event("add", _value, socket) do
    {:noreply, socket}
  end

  @impl true
  def handle_event("edit", %{"item_id" => _item_id} = _values, socket) do
    {:noreply, socket}
  end

  @impl true
  def handle_event("delete:", %{"item_id" => _item_id} = _values, socket) do
    {:noreply, socket}
  end
end
