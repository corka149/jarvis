defmodule JarvisWeb.InvitationView do
  use JarvisWeb, :view

  def accept_button(conn, invitation) do
    link(
      "✅",
      to: Routes.invitation_path(conn, :accept, invitation),
      class: "pure-button primary-button"
    )
  end

  def decline_button(conn, invitation) do
    link(
      "❌",
      to: Routes.invitation_path(conn, :delete, invitation),
      class: "pure-button secondary-button",
      method: :delete
    )
  end
end
