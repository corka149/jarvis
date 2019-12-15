defmodule JarvisWeb.InvitationView do
  use JarvisWeb, :view

  alias JarvisWeb.InvitationView
  alias JarvisWeb.UserView
  alias JarvisWeb.UserGroupView

  def render("index.json", %{
        received_invitations: received_invitations,
        created_invitations: created_invitations,
        memberships: memberships
      }) do
        IO.inspect memberships
    %{
      received_invitations: render_many(received_invitations, InvitationView, "show.json"),
      created_invitations: render_many(created_invitations, InvitationView, "show.json"),
      memberships: render_many(Enum.map(memberships, &(&1.user_group)), UserGroupView, "show.json")
    }
  end

  def render("show.json", %{invitation: invitation}) do
    IO.inspect invitation
    %{
      id: invitation.id,
      host: render_one(invitation.host, UserView, "show.json"),
      invited_into: render_one(invitation.usergroup, UserGroupView, "show.json"),
      invitee_email: invitation.invitee_email
    }
  end
end
