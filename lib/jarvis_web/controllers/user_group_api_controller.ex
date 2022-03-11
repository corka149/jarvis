defmodule JarvisWeb.UserGroupApiController do
  use JarvisWeb, :controller

  alias Jarvis.AccountsRepo

  action_fallback JarvisWeb.FallbackController

  plug JarvisWeb.Plugs.RequireAuthentication

  def index(conn, _params) do
    user_groups = AccountsRepo.list_usergroups_by_membership_or_owner(conn.assigns.user)
    render(conn, "index.json", user_groups_api: user_groups)
  end
end
