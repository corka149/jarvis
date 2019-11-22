defmodule Jarvis.Finances.TransactionAuthorization do
  @moduledoc """
  Defines who can access transactions.
  """
  alias Jarvis.Finances

  @behaviour JarvisWeb.AuthorizationBorder

  @impl JarvisWeb.AuthorizationBorder
  def is_allowed_to_cross?(user, transaction_id) do
    transaction = Finances.get_transaction!(transaction_id)
    transaction.created_by == user.id
  end
end
