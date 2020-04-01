defmodule JarvisWeb.ShoppingListView do
  @moduledoc """
  This view represents all possible response structures.
  """
  use JarvisWeb, :view

  def edit_button(conn) do
    link(
      dgettext("shoppinglists", "Create list"),
      to: Routes.shopping_list_path(conn, :new),
      class: "btn primary-btn"
    )
  end
end
