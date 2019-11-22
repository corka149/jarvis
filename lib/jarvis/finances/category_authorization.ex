defmodule Jarvis.Finances.CategoryAuthorization do
  alias Jarvis.Finances

  @behaviour JarvisWeb.AuthorizationBorder

  @impl JarvisWeb.AuthorizationBorder
  def is_allowed_to_cross?(user, category_id) do
    category = Finances.get_category!(category_id)
    category.created_by == user.id
  end
end
