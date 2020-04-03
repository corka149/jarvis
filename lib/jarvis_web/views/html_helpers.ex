defmodule JarvisWeb.HtmlHelpers do
  alias Phoenix.HTML

  @moduledoc """
  Predefined collection of html elements.
  """

  @doc """
  Creates a back button that goes back in history.
  """
  def back_button() do
    ~s"""
    <button action="action" onclick="window.history.go(-1); return false;" type="button"
      class="btn-floating primary-btn">
      <i class="material-icons">arrow_back</i>
    </button>
    """ |> HTML.raw()
  end

  @doc """
  Create floating create button
  """
  def add_button(route) do
    HTML.Link.link(
      HTML.raw("<i class='material-icons'>add</i>"),
      to: route,
      class: "btn-floating primary-btn"
    )
  end
end
