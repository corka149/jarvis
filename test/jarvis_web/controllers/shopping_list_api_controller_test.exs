defmodule JarvisWeb.Controllers.ShoppingListApiControllerTest do
  use JarvisWeb.ConnCase
  use Plug.Test

  import Jarvis.TestHelper

  alias Jarvis.AccountsRepo
  alias Jarvis.ShoppingListsRepo

  test "Get shopping list with valid token", %{conn: conn} do
    # Arrange
    group = gen_test_data(:user_group)
    user = group.user
    api_token = Ecto.UUID.generate()

    {:ok, _user} = AccountsRepo.update_user(user, %{"api_token" => api_token})

    {:ok, shopping_list} =
      ShoppingListsRepo.create_shopping_list(
        %{done: false, planned_for: ~D[2021-04-17]},
        group
      )

    {:ok, product} = ShoppingListsRepo.create_product(%{amount: 2, name: "apples"}, shopping_list)

    url = Routes.shopping_list_api_path(conn, :index)

    # Act
    response =
      conn
      |> put_req_header("accept", "application/json")
      |> put_req_header("authorization", api_token)
      |> get(url)

    # Assert
    assert response.status == 200

    [sl_json] = Jason.decode!(response.resp_body)["data"]

    assert sl_json["id"] == shopping_list.id

    [product_json] = sl_json["products"]
    assert product_json["id"] == product.id
    assert product_json["name"] == product.name
    assert product_json["amount"] == product.amount
  end

  test "Get no shopping list with invalid token", %{conn: conn} do
    # Arrange
    group = gen_test_data(:user_group)
    user = group.user
    api_token = Ecto.UUID.generate()

    {:ok, _user} = AccountsRepo.update_user(user, %{"api_token" => api_token})

    {:ok, _shopping_list} =
      ShoppingListsRepo.create_shopping_list(
        %{done: true, planned_for: ~D[2021-04-17]},
        group
      )

    url = Routes.shopping_list_api_path(conn, :index)
    other_token = Ecto.UUID.generate()

    # Act
    response =
      conn
      |> put_req_header("accept", "application/json")
      |> put_req_header("authorization", other_token)
      |> get(url)

    # Assert
    assert response.status == 401
  end
end
