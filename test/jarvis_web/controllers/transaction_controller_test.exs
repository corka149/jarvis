defmodule JarvisWeb.TransactionControllerTest do
  use JarvisWeb.ConnCase
  use Plug.Test

  import Jarvis.TestHelper

  alias Jarvis.Finances
  alias Jarvis.Finances.Transaction

  @create_attrs %{
    description: "some description",
    executed_on: ~N[2010-04-17 14:00:00],
    recurring: true,
    value: 120.5
  }
  @update_attrs %{
    description: "some updated description",
    executed_on: ~N[2011-05-18 15:01:01],
    recurring: false,
    value: 456.7
  }
  @invalid_attrs %{description: nil, executed_on: nil, recurring: nil, value: nil}

  @valid_attrs_user %{
    email: "someemail@test.xyz",
    name: "some name",
    provider: "some provider",
    token: "some token"
  }
  @valid_attrs_category %{name: "some name"}

  def fixture(:transaction) do
    {:ok, creator} = Jarvis.Accounts.create_user(update_with_unique_email(@valid_attrs_user))
    {:ok, category} = Finances.create_category(@valid_attrs_category, creator)
    {:ok, transaction} = Finances.create_transaction(@create_attrs, creator, category)
    transaction
  end

  setup %{conn: conn} do
    {:ok, creator} = Jarvis.Accounts.create_user(@valid_attrs_user)
    {:ok, category} = Finances.create_category(@valid_attrs_category, creator)

    conn =
      conn
      |> put_req_header("accept", "application/json")
      |> init_test_session(user_id: creator.id)

    {:ok, conn: conn, category: category}
  end

  describe "index" do
    test "lists all transactions", %{conn: conn} do
      conn = get(conn, Routes.transaction_path(conn, :index))
      assert json_response(conn, 200) == []
    end
  end

  describe "create transaction" do
    test "renders transaction when data is valid", %{conn: conn, category: category} do
      create_attrs = Map.put(@create_attrs, :category_id, category.id)
      conn = post(conn, Routes.transaction_path(conn, :create), transaction: create_attrs)
      assert %{"id" => id} = json_response(conn, 201)

      conn = get(conn, Routes.transaction_path(conn, :show, id))

      assert %{
               "id" => id,
               "description" => "some description",
               "executed_on" => "2010-04-17T14:00:00",
               "recurring" => true,
               "value" => 120.5
             } = json_response(conn, 200)
    end

    test "renders errors when data is invalid", %{conn: conn} do
      conn = post(conn, Routes.transaction_path(conn, :create), transaction: @invalid_attrs)
      assert json_response(conn, 422)["errors"] != %{}
    end
  end

  describe "update transaction" do
    setup [:create_transaction]

    test "renders transaction when data is valid", %{
      conn: conn,
      transaction: %Transaction{id: id} = transaction
    } do
      conn =
        conn
        |> init_test_session(user_id: transaction.created_by)
        |> put(Routes.transaction_path(conn, :update, transaction), transaction: @update_attrs)

      assert %{"id" => ^id} = json_response(conn, 200)

      conn = get(conn, Routes.transaction_path(conn, :show, id))

      assert %{
               "id" => id,
               "description" => "some updated description",
               "executed_on" => "2011-05-18T15:01:01",
               "recurring" => false,
               "value" => 456.7
             } = json_response(conn, 200)
    end

    test "renders errors when data is invalid", %{conn: conn, transaction: transaction} do
      conn =
        conn
        |> init_test_session(user_id: transaction.created_by)
        |> put(Routes.transaction_path(conn, :update, transaction), transaction: @invalid_attrs)

      assert json_response(conn, 422)["errors"] != %{}
    end

    test "try update without authorization", %{conn: conn, transaction: transaction} do
      {:ok, creator} =
        update_with_unique_email(@valid_attrs_user)
        |> Jarvis.Accounts.create_user()

      conn =
        conn
        |> init_test_session(user_id: creator.id)
        |> put(Routes.transaction_path(conn, :update, transaction), transaction: @invalid_attrs)

      response(conn, 403) =~ "You are not allow to do this"
    end
  end

  describe "delete transaction" do
    setup [:create_transaction]

    test "deletes chosen transaction", %{conn: conn, transaction: transaction} do
      conn =
        conn
        |> init_test_session(user_id: transaction.created_by)
        |> delete(Routes.transaction_path(conn, :delete, transaction))

      assert response(conn, 204)

      assert_error_sent 404, fn ->
        get(conn, Routes.transaction_path(conn, :show, transaction))
      end
    end

    test "try delete chosen transaction without owning it", %{
      conn: conn,
      transaction: transaction
    } do
      conn =
        conn
        |> delete(Routes.transaction_path(conn, :delete, transaction))

      assert response(conn, 403)
    end
  end

  defp create_transaction(_) do
    transaction = fixture(:transaction)
    {:ok, transaction: transaction}
  end
end
