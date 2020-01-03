defmodule Jarvis.Accounts.UserAuthorization do
  @moduledoc """
  Defines who can access users.
  """
  @behaviour JarvisWeb.AuthorizationBorder

  @impl JarvisWeb.AuthorizationBorder
  def is_allowed_to_cross?(_user, "current") do
    true
  end

  def is_allowed_to_cross?(user, requested_user_id) when is_bitstring(requested_user_id) do
    case Integer.parse(requested_user_id) do
      :error -> false
      {requested_user_id, _} -> user.id == requested_user_id
    end
  end

  def is_allowed_to_cross?(user, requested_user_id) do
    user.id == requested_user_id
  end
end
