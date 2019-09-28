defmodule JarvisWeb.ItemLiveTest do
  use JarvisWeb.ConnCase
  use Plug.Test
  import Phoenix.LiveViewTest
  alias Jarvis.Accounts
  alias Jarvis.ShoppingLists

  @create_attrs %{done: false, planned_for: ~D[2010-04-17]}
  @valid_attrs_group %{name: "some name"}
  @valid_attrs_user %{
    email: "some email",
    name: "some name",
    provider: "some provider",
    token: "some token"
  }


  def create_shopping_list_and_login(%{conn: conn}) do
    # create list and depending entities
    {_, user} = Accounts.create_user(@valid_attrs_user)
    {_, group} = Accounts.create_user_group(@valid_attrs_group, user)
    {:ok, shopping_list} = ShoppingLists.create_shopping_list(@create_attrs, group)

    # login
    conn = init_test_session(conn, user_id: user.id)

    {:ok, shopping_list: shopping_list, group: group, user: user, conn: conn}
  end

  setup [:create_shopping_list_and_login]

  test "disconnected and connected mount", %{conn: conn, shopping_list: shopping_list} do
    conn = get(conn, item_live_path(conn, shopping_list))
    assert html_response(conn, 200) =~ "Shopping list for"

    {:ok, _view, html} = live(conn)
    assert html =~ "<h2>\nShopping list for 2010-04-17</h2>"
  end

  test "adding items", %{conn: conn, shopping_list: shopping_list} do
    {:ok, view, _html} = live(conn, item_live_path(conn, shopping_list))

    assert render_submit(view, :save, %{item: %{name: "apple wine", amount: 5}}) =~ "apple wine"
    assert render_submit(view, :save, %{item: %{name: "bread", amount: 2}}) =~ "bread"
  end

  test "delete an item", %{conn: conn, shopping_list: shopping_list} do
    {:ok, view, _html} = live(conn, item_live_path(conn, shopping_list))

    assert render_submit(view, :save, %{item: %{name: "apple wine", amount: 5}}) =~ "apple wine"
    %{id: id} = ShoppingLists.list_items_by_shopping_list(shopping_list) |> List.first()
    assert render_click(view, "delete/" <> Integer.to_string(id)) =~ "<h2>\nShopping list for 2010-04-17</h2>"
    items = ShoppingLists.list_items_by_shopping_list(shopping_list)
    assert length(items) == 0
  end

  test "update an item", %{conn: conn, shopping_list: shopping_list} do
    {:ok, view, _html} = live(conn, item_live_path(conn, shopping_list))
    assert render_submit(view, :save, %{item: %{name: "apple wine", amount: 5}}) =~ "apple wine"

    %{id: id} = ShoppingLists.list_items_by_shopping_list(shopping_list) |> List.first()
    assert render_click(view, "edit/" <> Integer.to_string(id)) =~ "apple wine"
    assert render_submit(view, :save, %{item: %{id: id, name: "beer", amount: 3}}) =~ "beer"

    %{name: name, amount: amount} = ShoppingLists.list_items_by_shopping_list(shopping_list) |> List.first()
    assert "beer" = name
    assert 3 = amount
  end

  defp item_live_path(conn, shopping_list) do
    Routes.live_path(conn, JarvisWeb.ItemLive, shopping_list.id)
  end
end
