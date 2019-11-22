defmodule JarvisWeb.InvitationController do
  alias Jarvis.Accounts

  use JarvisWeb, :controller

  action_fallback JarvisWeb.FallbackController

  plug JarvisWeb.Plugs.RequireAuthentication

  def index(conn, _params) do
    render(conn, "index.json",
      received_invitations: Accounts.list_initations_by_invitee(conn.assigns.user),
      created_invitations: Accounts.list_invitations_by_host(conn.assigns.user),
      memberships: Accounts.list_usergroups_by_membership(conn.assigns.user)
    )
  end

  def create(conn, %{"invitation" => invitation_params}) do
    invite_user_to_group(conn.assigns.user, invitation_params)
    send_resp(conn, :no_content, "")
  end

  def delete(conn, %{"id" => id}) do
    case Accounts.get_invitation(id) do
      {:ok, invitation} ->
        {:ok, _invitation} = Accounts.delete_invitation(invitation)
        send_resp(conn, :no_content, "")
    end
  end

  def accept(conn, %{"id" => id}) do
    invitation = Accounts.get_invitation!(id)

    if invitation.invitee.id == conn.assigns.user.id do
      {:ok, _} = Accounts.add_user_to_group(invitation.invitee, invitation.usergroup)
      {:ok, _} = Accounts.delete_invitation(invitation)

      send_resp(conn, :no_content, "")
    else
      conn
      |> send_resp(403, dgettext("errors", "You are not allow to do this"))
    end
  end

  ## Private functions

  # Creates a new invitation if an user exists with the provided name.
  defp invite_user_to_group(host, invitation_params) do
    user_group = invitation_params["usergroup_id"] |> Accounts.get_user_group!()

    case Accounts.is_group_owner(host, user_group) &&
           Accounts.get_user_by_name(invitation_params["invitee_name"]) do
      false -> nil
      nil -> nil
      invitee -> Accounts.create_invitation(invitation_params, user_group, host, invitee)
    end
  end
end
