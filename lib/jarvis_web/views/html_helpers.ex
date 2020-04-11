defmodule JarvisWeb.HtmlHelpers do
  alias Phoenix.HTML

  @moduledoc """
  Predefined collection of html elements.
  """

  @doc """
  Creates a back button that goes back in history.
  """
  def back_button(route) do
    HTML.Link.link(
      HTML.raw("<i class='material-icons'>arrow_back</i>"),
      to: route,
      class: "btn-floating secondary-btn"
    )
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

  @doc """
  Create floating edit button
  """
  def edit_button(route) do
    HTML.Link.link(
      HTML.raw("<i class='material-icons'>create</i>"),
      to: route,
      class: "btn-floating primary-btn"
    )
  end

  def save_button do
    HTML.Form.submit(
      HTML.raw("<i class='material-icons'>save</i>"),
      class: "btn-floating primary-btn"
    )
  end
end
