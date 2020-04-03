defmodule JarvisWeb.HtmlHelpers do
  require Phoenix.HTML

  @moduledoc """
  Predefined collection of html elements.
  """

  @doc """
  Creates a back button
  """
  def back_button() do
    ~s"""
    <button action="action" onclick="window.history.go(-1); return false;" type="button"
      class="btn-floating primary-btn">
      <i class="material-icons">arrow_back</i>
    </button>
    """ |> Phoenix.HTML.raw()
  end

end
