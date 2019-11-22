defmodule JarvisWeb.TransactionView do
  use JarvisWeb, :view
  alias JarvisWeb.TransactionView

  def render("index.json", %{transactions: transactions}) do
    render_many(transactions, TransactionView, "transaction.json")
  end

  def render("show.json", %{transaction: transaction}) do
    render_one(transaction, TransactionView, "transaction.json")
  end

  def render("transaction.json", %{transaction: transaction}) do
    %{
      id: transaction.id,
      description: transaction.description,
      value: transaction.value,
      recurring: transaction.recurring,
      executed_on: transaction.executed_on
    }
  end
end
