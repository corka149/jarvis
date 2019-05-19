defmodule JarvisWeb.ItemLive do
  use Phoenix.LiveView
  alias JarvisWeb.ItemView

  alias Jarvis.ShoppingLists
  alias Jarvis.ShoppingLists.Item

  @doc """
  Will be call first for new connections
  """
  def mount(%{path_params: %{"id" => shopping_list_id}} = session, socket) do
    IO.puts "================session"
    IO.inspect session
    IO.puts "================"

    socket =  socket
              |> assign(%{changeset: ShoppingLists.change_item(%Item{})})
              |> assign(:shopping_list, ShoppingLists.get_shopping_list!(shopping_list_id))
    {:ok, socket}
  end

  @doc """
  Renders the static HTML after mounting the session.
  """
  def render(assigns) do
    ItemView.render("index.html", assigns)
  end

  def handle_event("save",
                  %{"item" => item} = data,
                  %{assigns: %{shopping_list: shopping_list}} = socket) do
    #IO.puts "================data"
    #IO.inspect data
    #IO.puts "================socket"
    #IO.inspect socket
    #IO.puts "================"
    #IO.inspect item
    #IO.puts "================"
    case  ShoppingLists.create_item(item, shopping_list) do
      {:ok, _} ->
        {
          :noreply,
          socket
          |> put_flash(:info, "item created")
          |> assign(changeset: ShoppingLists.change_item(%Item{}))
          |> IO.inspect
        }
      {:error, %Ecto.Changeset{} = changeset} ->
        {
          :noreply,
          socket
          |> assign(changeset: changeset)
        }
    end
  end

  def handle_event("delete", _, socket) do
    {:noreply, socket}
  end
end
