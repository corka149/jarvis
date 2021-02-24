defmodule JarvisWeb.UserGroupApiView do
  @moduledoc """
  This view represents all possible response structure.
  """
  use JarvisWeb, :view
  alias JarvisWeb.UserGroupApiView

  def render("index.json", %{user_groups_api: user_groups}) do
    %{data: render_many(user_groups, UserGroupApiView, "user_group.json")}
  end

  def render("show.json", %{user_group_api: user_group}) do
    %{data: render_one(user_group, UserGroupApiView, "user_group.json")}
  end

  def render("user_group.json", %{user_group_api: user_group}) do
    %{id: user_group.id, name: user_group.name}
  end
end
