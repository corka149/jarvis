defmodule JarvisWeb.ItemControllerTest do
  alias Jarvis.ShoppingLists
  use Plug.Test
  use JarvisWeb.ConnCase

  @create_attrs %{amount: 2, name: "apples"}
  @update_attrs %{amount: 5, name: "cherries"}
  @invalid_attrs %{amount: nil, name: 12345}

  @valid_attrs_shopping_list %{
    done: true,
    planned_for: ~D[2010-04-17]
  }
  @valid_attrs_group %{name: "some name"}
  @valid_attrs_user %{
    email: "some email",
    name: "some name",
    provider: "some provider",
    token: "some token"
  }

  def fixture(:item) do
    {:ok, user} = Jarvis.Accounts.create_user(@valid_attrs_user)
    {:ok, group} = Jarvis.Accounts.create_user_group(@valid_attrs_group, user)
    {:ok, shopping_list} = ShoppingLists.create_shopping_list(@valid_attrs_shopping_list, group)
    {:ok, item} = ShoppingLists.create_item(@create_attrs, shopping_list)
    {item, shopping_list, group, user}
  end

  defp create_item(_) do
    {item, shopping_list, _group, user} = fixture(:item)
    {:ok, item: item, shopping_list: shopping_list, user: user}
  end

  describe "index" do
    setup [:create_item]

    test "lists all items", %{conn: conn, user: user, shopping_list: shopping_list} do
      conn = init_test_session(conn, user_id: user.id)
              |> get(Routes.item_path(conn, :index, shopping_list.id))

      items = json_response(conn, 200)
      assert is_list(items)
    end
  end

end
