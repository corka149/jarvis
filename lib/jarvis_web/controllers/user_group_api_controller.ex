defmodule JarvisWeb.UserGroupApiController do
  use JarvisWeb, :controller

  alias Jarvis.Accounts

  action_fallback JarvisWeb.FallbackController

  def index(conn, _params) do
    #  Accounts.list_usergroups_by_membership_or_owner(conn.assigns.user)
    user_groups = Accounts.list_usergroups()
    render(conn, "index.json", user_groups_api: user_groups)
  end
end
