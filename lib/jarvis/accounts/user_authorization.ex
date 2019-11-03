defmodule Jarvis.Accounts.UserAuthorization do

  @behaviour JarvisWeb.AuthorizationBorder

  @impl JarvisWeb.AuthorizationBorder
  def is_allowed_to_cross?(user, requested_user_id) when is_bitstring(requested_user_id) do
    {requested_user_id, _} = Integer.parse(requested_user_id)
    user.id == requested_user_id
  end

  def is_allowed_to_cross?(user, requested_user_id) do
    user.id == requested_user_id
  end
end
