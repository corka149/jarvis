defmodule JarvisWeb.InvitationController do
  use JarvisWeb, :controller

  alias Jarvis.Accounts
  alias Jarvis.Accounts.Invitation

  def index(conn, _params) do
    invitations = Accounts.list_invitations()
    render(conn, "index.html", invitations: invitations)
  end

  def new(conn, _params) do
    user_groups = Accounts.list_usergroups_by_owner(conn.assigns.user.id)
                  |> Enum.map(fn ug -> {ug.name, ug.id} end)
    changeset = Accounts.change_invitation(%Invitation{})
    render(conn, "new.html", changeset: changeset, user_groups: user_groups)
  end

  def create(conn, %{"invitation" => invitation_params}) do
    case Accounts.create_invitation(invitation_params) do
      {:ok, invitation} ->
        conn
        |> put_flash(:info, "Invitation created successfully.")
        |> redirect(to: Routes.invitation_path(conn, :show, invitation))

      {:error, %Ecto.Changeset{} = changeset} ->
        render(conn, "new.html", changeset: changeset)
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
    |> put_flash(:info, "Invitation deleted successfully.")
    |> redirect(to: Routes.invitation_path(conn, :index))
  end
end
