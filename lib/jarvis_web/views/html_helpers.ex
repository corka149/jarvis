defmodule JarvisWeb.HtmlHelpers do
  alias Phoenix.HTML
  import JarvisWeb.Gettext

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
      class: "pure-button secondary-button icon-button"
    )
  end

  @doc """
  Create floating create button
  """
  def add_button(route) do
    HTML.Link.link(
      HTML.raw("<i class='material-icons'>add</i>"),
      to: route,
      class: "pure-button primary-button icon-button"
    )
  end

  @doc """
  Create floating edit button
  """
  def edit_button(route) do
    HTML.Link.link(
      HTML.raw("<i class='material-icons'>create</i>"),
      to: route,
      class: "pure-button primary-button icon-button"
    )
  end

  @doc """
  Create floating delete button
  """
  def delete_button(route) do
    HTML.Link.link(
      HTML.raw("<i class='material-icons'>delete</i>"),
      to: route,
      class: "pure-button danager-button icon-button",
      method: :delete,
      data: [confirm: gettext("Are you sure?")]
    )
  end

  def save_button do
    HTML.Form.submit(
      HTML.raw("<i class='material-icons'>save</i>"),
      class: "pure-button primary-button icon-button"
    )
  end
end
