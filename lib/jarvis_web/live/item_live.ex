defmodule JarvisWeb.ItemLive do
  use Phoenix.LiveView

  alias JarvisWeb.ItemView
  alias Jarvis.Accounts
  alias Jarvis.Accounts.User
  alias Jarvis.ShoppingLists
  alias Jarvis.ShoppingLists.Item

  @doc """
  Will be call first for new connections
  """
  def mount(%{path_params: %{"id" => shopping_list_id}, user_id: user_id}, socket) do
    user = Accounts.get_user!(user_id)
    set_lang(user)

    shopping_list = ShoppingLists.get_shopping_list!(shopping_list_id)
    items = ShoppingLists.list_items_by_shopping_list(shopping_list)

    socket =  socket
              |> assign(:user, user)
              |> assign(%{changeset: ShoppingLists.change_item(%Item{})})
              |> assign(:shopping_list, shopping_list)
              |> assign(items: items)
    {:ok, socket}
  end

  @doc """
  Renders the static HTML after mounting the session.
  """
  def render(assigns) do
    ItemView.render("index.html", assigns)
  end

  def handle_event("save",
                  %{"item" => item},
                  %{assigns: %{shopping_list: shopping_list}} = socket) do

    case ShoppingLists.create_or_update_item(item, shopping_list) do
      {:ok, _} ->
        display_success(socket, shopping_list)

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, changeset: changeset)}
    end
  end

  def handle_event("delete/" <> id, _, %{assigns: %{shopping_list: shopping_list}} = socket) do
    id
    |> String.to_integer()
    |> ShoppingLists.get_item!()
    |> ShoppingLists.delete_item()

    items = ShoppingLists.list_items_by_shopping_list(shopping_list)

    {:noreply, assign(socket, items: items)}
  end

  def handle_event("edit/" <> id, _, %{assigns: %{shopping_list: shopping_list}} = socket) do
    item = id
           |> String.to_integer()
           |> ShoppingLists.get_item!()

    items = ShoppingLists.list_items_by_shopping_list(shopping_list)

    {
      :noreply,
      socket
      |> assign(%{changeset: ShoppingLists.change_item(item)})
      |> assign(items: items)
    }
  end

  defp display_success(socket, shopping_list) do
    items = ShoppingLists.list_items_by_shopping_list(shopping_list)
    socket = socket
            |> put_flash(:info, "item saved")
            |> assign(changeset: ShoppingLists.change_item(%Item{}))
            |> assign(items: items)
    {:noreply, socket}
  end

  defp set_lang(%User{} = user) do
    Gettext.put_locale user.default_language
  end
end
