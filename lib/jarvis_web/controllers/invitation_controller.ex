defmodule JarvisWeb.InvitationController do
  use JarvisWeb, :controller

  alias Jarvis.Accounts
  alias Jarvis.Accounts.Invitation

  def index(conn, _params) do
    received_invitations = Accounts.list_initations_by_invitee(conn.assigns.user)
    created_invitations = Accounts.list_invitations_by_host(conn.assigns.user)
    render(conn, "index.html", received_invitations: received_invitations, created_invitations: created_invitations)
  end

  def new(conn, _params) do
    user_groups = Accounts.list_usergroups_by_owner(conn.assigns.user.id)
                  |> Enum.map(fn ug -> {ug.name, ug.id} end)
    changeset = Accounts.change_invitation(%Invitation{})
    render(conn, "new.html", changeset: changeset, user_groups: user_groups)
  end

  def create(conn, %{"invitation" => invitation_params}) do
    invite_user_to_group(conn.assigns.user, invitation_params)

    conn
    |> put_flash(:info, dgettext("accounts", "Invitation created successfully."))
    |> redirect(to: Routes.invitation_path(conn, :index))
  end

  # Creates a new invatation if an user exists with the provided name.
  defp invite_user_to_group(host, invitation_params) do
    user_group = invitation_params["usergroup_id"] |> Accounts.get_user_group!()

    case Accounts.get_user_by_name(invitation_params["invitee_name"]) do
      nil -> nil
      invitee -> Accounts.create_invitation(invitation_params, user_group, host, invitee)
    end
  end

  def show(conn, %{"id" => id}) do
    invitation = Accounts.get_invitation!(id)
    render(conn, "show.html", invitation: invitation)
  end

  def delete(conn, %{"id" => id}) do
    invitation = Accounts.get_invitation!(id)
    {:ok, _invitation} = Accounts.delete_invitation(invitation)

    conn
    |> put_flash(:info, gettext("Invitation deleted successfully."))
    |> redirect(to: Routes.invitation_path(conn, :index))
  end

  def accept(conn, %{"id" => id}) do
    invitation = Accounts.get_invitation!(id)
    {:ok, _} = Accounts.add_user_to_group(invitation.invitee, invitation.usergroup)
    {:ok, _} = Accounts.delete_invitation(invitation)

    conn
    |> put_flash(:info, gettext("Accepted invitation."))
    |> redirect(to: Routes.invitation_path(conn, :index))
  end
end
