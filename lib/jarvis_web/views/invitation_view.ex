defmodule JarvisWeb.InvitationView do
  use JarvisWeb, :view

  alias JarvisWeb.InvitationView

  def render("index.json", %{
    received_invitations: received_invitations,
    created_invitations: created_invitations,
    memberships: _memberships,
  }) do
    %{
      received_invitations: render_many(received_invitations, InvitationView, "show.json"),
      created_invitations: render_many(created_invitations, InvitationView, "show.json"),
      memberships: []
    }
  end

  def render("show.json", %{invitation: invitation}) do
    %{
      invitee_name: invitation.invitee_name
    }
  end

end
