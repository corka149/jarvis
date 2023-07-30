defmodule JarvisWeb.InvitationHTML do
  use JarvisWeb, :html

  embed_templates "invitation_html/*"

  def accept_button(conn, invitation) do
    link(
      raw("<i class='material-icons'>check</i>"),
      to: Routes.invitation_path(conn, :accept, invitation),
      class: "pure-button primary-button icon-button"
    )
  end

  def decline_button(conn, invitation) do
    link(
      raw("<i class='material-icons'>clear</i>"),
      to: Routes.invitation_path(conn, :delete, invitation),
      class: "pure-button secondary-button icon-button",
      method: :delete
    )
  end
end
