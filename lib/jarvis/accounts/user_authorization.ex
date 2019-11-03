defmodule Jarvis.Accounts.UserAuthorization do

  @behaviour JarvisWeb.AuthorizationBorder

  @impl JarvisWeb.AuthorizationBorder
  def is_allowed_to_cross?(user, requested_user_id) do
    user.id == requested_user_id
  end
end
