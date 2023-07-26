defmodule JarvisWeb.InvitationController do
  alias Jarvis.Accounts.Invitation
  alias Jarvis.Accounts.User
  alias Jarvis.AccountsAppService
  alias Jarvis.AccountsRepo

  use JarvisWeb, :controller

  action_fallback JarvisWeb.FallbackController

  plug JarvisWeb.Plugs.RequireAuthentication

  def index(conn, _params) do
    render(conn, "index.html",
      received_invitations: AccountsRepo.list_initations_by_invitee(conn.assigns.user),
      created_invitations: AccountsRepo.list_invitations_by_host(conn.assigns.user),
      memberships: AccountsRepo.list_usergroups_by_membership(conn.assigns.user)
    )
  end

  def new(conn, _params) do
    changeset = AccountsRepo.change_invitation(%Invitation{})

    render(conn, "new.html",
      changeset: changeset,
      user_groups: group_names_with_ids(conn.assigns.user)
    )
  end

  def create(conn, %{"invitation" => invitation_params}) do
    AccountsAppService.invite_user_to_group(conn.assigns.user, invitation_params)

    conn
    |> put_flash(:info, dgettext("accounts", "Invitation submitted."))
    |> redirect(to: Routes.invitation_path(conn, :index))
  end

  def delete(conn, %{"id" => id}) do
    AccountsAppService.delete_invitation(id)

    redirect(conn, to: Routes.invitation_path(conn, :index))
  end

  def accept(conn, %{"id" => invitation_id}) do
    case AccountsAppService.accept_invitation(invitation_id, conn.assigns.user.id) do
      :ok ->
        redirect(conn, to: Routes.invitation_path(conn, :index))

      {:error, _} ->
        conn
        |> send_resp(403, dgettext("errors", "You are not allow to do this"))
    end
  end

  ## Private functions

  defp group_names_with_ids(%User{} = user) do
    AccountsRepo.list_usergroups_by_membership_or_owner(user)
    |> Enum.map(&{&1.name, &1.id})
  end
end
