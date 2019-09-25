defmodule JarvisWeb.ItemLive do
  use Phoenix.LiveView

  import JarvisWeb.Gettext

  alias JarvisWeb.ItemView
  alias Jarvis.Accounts
  alias Jarvis.Accounts.User
  alias Jarvis.ShoppingLists
  alias Jarvis.ShoppingLists.Item
  alias JarvisWeb.Plugs.CheckListOwnerGroup
  alias JarvisWeb.Router.Helpers, as: Routes

  @doc """
  Will be call first for new connections
  """
  @impl true
  def mount(%{user_id: user_id}, socket) do
    {:ok, socket |> assign(:user_id, user_id)}
  end

  @doc """
  The handle_params/3 callback is invoked after mount/2.
  https://hexdocs.pm/phoenix_live_view/Phoenix.LiveView.html#c:handle_params/3
  """
  @impl true
  def handle_params(%{"id" => shopping_list_id}, _uri, socket) do
    user_id = socket.assigns[:user_id]
    if is_user_authorized?(user_id, shopping_list_id) do
      Accounts.get_user!(user_id) |> set_lang()
      mount_is_allowed(socket, shopping_list_id)
    else
      redirect_to_landing_page(socket)
    end
  end

  @doc """
  Renders the static HTML after mounting the session.
  """
  @impl true
  def render(assigns) do
    ItemView.render("index.html", assigns)
  end

    ####################################
   #   Handle messages from client    #
  ####################################

  @impl true
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

  @impl true
  def handle_event("delete/" <> id, _, %{assigns: %{shopping_list: shopping_list}} = socket) do
    id
    |> String.to_integer()
    |> ShoppingLists.get_item!()
    |> ShoppingLists.delete_item()

    items = ShoppingLists.list_items_by_shopping_list(shopping_list)

    {:noreply, assign(socket, items: items)}
  end

  @impl true
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

    ####################################
   #             Helpers              #
  ####################################

  defp mount_is_allowed(socket, shopping_list_id) do
    shopping_list = ShoppingLists.get_shopping_list!(shopping_list_id)
    items = ShoppingLists.list_items_by_shopping_list(shopping_list)

    socket =  socket
                |> assign(%{changeset: ShoppingLists.change_item(%Item{})})
                |> assign(:shopping_list, shopping_list)
                |> assign(items: items)
      {:noreply, socket}
  end

  defp redirect_to_landing_page(socket) do
    { :stop,
      socket
      |> put_flash(:error, dgettext("errors", "You are not allow to do this!"))
      |> redirect(to: Routes.page_path(socket, :index))
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
    user
  end

  defp is_user_authorized?(nil, _), do: false

  defp is_user_authorized?(user_id, shopping_list_id) do
    Accounts.get_user!(user_id) |> CheckListOwnerGroup.is_authorized(shopping_list_id)
  end
end
