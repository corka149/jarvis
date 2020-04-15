defmodule JarvisWeb.InvitationView do
  use JarvisWeb, :view

  def accept_button(conn, invitation) do
    link(
      raw("<i class='material-icons'>check</i>"),
      to: Routes.invitation_path(conn, :accept, invitation),
      class: "btn-floating primary-btn"
    )
  end

  def decline_button(conn, invitation) do
    link(
      raw("<i class='material-icons'>clear</i>"),
      to: Routes.invitation_path(conn, :delete, invitation),
      class: "btn-floating secondary-btn",
      method: :delete
    )
  end
end
