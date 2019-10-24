defmodule JarvisWeb.UserGroupView do
  @moduledoc """
  This view represents all possible response structure.
  """
  use JarvisWeb, :view

  alias JarvisWeb.UserGroupView

  def render("index.json", %{user_groups: user_groups}) do
    render_many(user_groups, UserGroupView, "show.json")
  end

  def render("show.json", %{user_group: user_group}) do
    %{
      id: user_group.id,
      name: user_group.name
    }
  end

  def render("error.json", %{error: reason}) do
    %{
      scope: "user_groups",
      error: reason
    }
  end
end
