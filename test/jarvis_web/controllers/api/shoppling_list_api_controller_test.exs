defmodule JarvisWeb.Api.ShoppingListApiControllerTest do
  use JarvisWeb.ConnCase

  alias Jarvis.ShoppingLists

  @valid_attrs_user %{email: "some email", name: "some name", provider: "some provider", token: "some token"}
  @valid_attrs_group %{name: "some name"}
  @valid_attrs_shopping_list %{done: false, planned_for: ~D[2010-04-17]}

  setup %{conn: conn} do
    {:ok, conn: put_req_header(conn, "accept", "application/json")}
  end

  test "request open shopping lists", %{conn: conn} do
    {_, user} = Jarvis.Accounts.create_user(@valid_attrs_user)
    {_, group} = Jarvis.Accounts.create_user_group(@valid_attrs_group, user)
    {:ok, shopping_list} = ShoppingLists.create_shopping_list(@valid_attrs_shopping_list, group)
    # First list
    ShoppingLists.create_item(%{"amount" => 5, "name" => "fruits"}, shopping_list)
    ShoppingLists.create_item(%{"amount" => 1, "name" => "milk"}, shopping_list)
    ShoppingLists.create_item(%{"amount" => 3, "name" => "water"}, shopping_list)
    # Second list
    {:ok, shopping_list} = ShoppingLists.create_shopping_list(@valid_attrs_shopping_list, group)
    ShoppingLists.create_item(%{"amount" => 5, "name" => "batteries"}, shopping_list)
    ShoppingLists.create_item(%{"amount" => 1, "name" => "pepper"}, shopping_list)
    ShoppingLists.create_item(%{"amount" => 1, "name" => "salt"}, shopping_list)

    conn = get(conn, Routes.shopping_list_api_path(conn, :list_open_lists))
    body = json_response(conn, 200)
    assert length(body) == 2
    [first | tail] = body
    [second | _] = tail
    assert %{"amount" => 5, "name" => "fruits"} in first["items"]
    assert %{"amount" => 1, "name" => "milk"} in first["items"]
    assert %{"amount" => 3, "name" => "water"} in first["items"]

    assert %{"amount" => 5, "name" => "batteries"} in second["items"]
    assert %{"amount" => 1, "name" => "pepper"} in second["items"]
    assert %{"amount" => 1, "name" => "salt"} in second["items"]
  end

end
