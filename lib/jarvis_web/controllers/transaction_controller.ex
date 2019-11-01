defmodule JarvisWeb.TransactionController do
  use JarvisWeb, :controller

  alias Jarvis.Finances
  alias Jarvis.Finances.Category
  alias Jarvis.Finances.Transaction

  action_fallback JarvisWeb.FallbackController

  plug JarvisWeb.Plugs.RequireAuth

  def index(conn, _params) do
    transactions = Finances.list_transactions()
    render(conn, "index.json", transactions: transactions)
  end

  def create(conn, %{"transaction" => transaction_params}) do
    category = get_category(transaction_params)

    with {:ok, %Transaction{} = transaction} <- Finances.create_transaction(transaction_params, conn.assigns.user, category) do
      conn
      |> put_status(:created)
      |> put_resp_header("location", Routes.transaction_path(conn, :show, transaction))
      |> render("show.json", transaction: transaction)
    end
  end

  def show(conn, %{"id" => id}) do
    transaction = Finances.get_transaction!(id)
    render(conn, "show.json", transaction: transaction)
  end

  def update(conn, %{"id" => id, "transaction" => transaction_params}) do
    transaction = Finances.get_transaction!(id)

    with {:ok, %Transaction{} = transaction} <- Finances.update_transaction(transaction, transaction_params) do
      render(conn, "show.json", transaction: transaction)
    end
  end

  def delete(conn, %{"id" => id}) do
    transaction = Finances.get_transaction!(id)

    with {:ok, %Transaction{}} <- Finances.delete_transaction(transaction) do
      send_resp(conn, :no_content, "")
    end
  end

  defp get_category(%{"category_id" => category_id} = _transaction_params) do
    Jarvis.Finances.get_category!(category_id)
  end

  defp get_category(_), do: %Category{}

end
