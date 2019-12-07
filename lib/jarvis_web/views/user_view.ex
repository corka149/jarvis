defmodule JarvisWeb.UserView do
  use JarvisWeb, :view
  alias JarvisWeb.UserView

  def render("index.json", %{users: users}) do
    render_many(users, UserView, "user.json")
  end

  def render("show.json", %{user: user}) do
    render_one(user, UserView, "user.json")
  end

  def render("user.json", %{user: user}) do
    %{
      name: user.name
    }
  end
end
