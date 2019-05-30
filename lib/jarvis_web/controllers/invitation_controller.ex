defmodule JarvisWeb.InvitationController do
  use JarvisWeb, :controller

  alias Jarvis.Accounts
  alias Jarvis.Accounts.Invitation

  def index(conn, _params) do
    invitations = Accounts.list_invitations()
    render(conn, "index.html", invitations: invitations)
  end

  def new(conn, _params) do
    changeset = Accounts.change_invitation(%Invitation{})
    render(conn, "new.html", changeset: changeset)
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

  def edit(conn, %{"id" => id}) do
    invitation = Accounts.get_invitation!(id)
    changeset = Accounts.change_invitation(invitation)
    render(conn, "edit.html", invitation: invitation, changeset: changeset)
  end

  def update(conn, %{"id" => id, "invitation" => invitation_params}) do
    invitation = Accounts.get_invitation!(id)

    case Accounts.update_invitation(invitation, invitation_params) do
      {:ok, invitation} ->
        conn
        |> put_flash(:info, "Invitation updated successfully.")
        |> redirect(to: Routes.invitation_path(conn, :show, invitation))

      {:error, %Ecto.Changeset{} = changeset} ->
        render(conn, "edit.html", invitation: invitation, changeset: changeset)
    end
  end

  def delete(conn, %{"id" => id}) do
    invitation = Accounts.get_invitation!(id)
    {:ok, _invitation} = Accounts.delete_invitation(invitation)

    conn
    |> put_flash(:info, "Invitation deleted successfully.")
    |> redirect(to: Routes.invitation_path(conn, :index))
  end
end
