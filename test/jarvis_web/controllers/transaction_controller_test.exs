defmodule JarvisWeb.TransactionControllerTest do
  use JarvisWeb.ConnCase

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

  def fixture(:transaction) do
    {:ok, transaction} = Finances.create_transaction(@create_attrs)
    transaction
  end

  setup %{conn: conn} do
    {:ok, conn: put_req_header(conn, "accept", "application/json")}
  end

  describe "index" do
    test "lists all transactions", %{conn: conn} do
      conn = get(conn, Routes.transaction_path(conn, :index))
      assert json_response(conn, 200) == []
    end
  end

  describe "create transaction" do
    test "renders transaction when data is valid", %{conn: conn} do
      conn = post(conn, Routes.transaction_path(conn, :create), transaction: @create_attrs)
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

    test "renders transaction when data is valid", %{conn: conn, transaction: %Transaction{id: id} = transaction} do
      conn = put(conn, Routes.transaction_path(conn, :update, transaction), transaction: @update_attrs)
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
      conn = put(conn, Routes.transaction_path(conn, :update, transaction), transaction: @invalid_attrs)
      assert json_response(conn, 422)["errors"] != %{}
    end
  end

  describe "delete transaction" do
    setup [:create_transaction]

    test "deletes chosen transaction", %{conn: conn, transaction: transaction} do
      conn = delete(conn, Routes.transaction_path(conn, :delete, transaction))
      assert response(conn, 204)

      assert_error_sent 404, fn ->
        get(conn, Routes.transaction_path(conn, :show, transaction))
      end
    end
  end

  defp create_transaction(_) do
    transaction = fixture(:transaction)
    {:ok, transaction: transaction}
  end
end