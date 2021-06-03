defmodule JarvisWeb.LiveHelpers do
  alias Phoenix.HTML
  import Phoenix.LiveView.Helpers
  import JarvisWeb.Gettext

  @doc """
  Renders a component inside the `JarvisWeb.ModalComponent` component.

  The rendered modal receives a `:return_to` option to properly update
  the URL when the modal is closed.

  ## Examples

      <%= live_modal JarvisWeb.UserLive.FormComponent,
        id: @user.id || :new,
        action: @live_action,
        user: @user,
        return_to: Routes.user_index_path(@socket, :index) %>
  """
  def live_modal(component, opts) do
    path = Keyword.fetch!(opts, :return_to)
    modal_opts = [id: :modal, return_to: path, component: component, opts: opts]
    live_component(JarvisWeb.ModalComponent, modal_opts)
  end

  @doc """
  Create floating create button
  """
  def add_button(route) do
    live_patch(
      HTML.raw("<i class='material-icons'>add</i>"),
      to: route,
      class: "pure-button primary-button icon-button"
    )
  end

  @doc """
  Create floating edit button
  """
  def edit_button(route) do
    live_patch(
      HTML.raw("<i class='material-icons'>create</i>"),
      to: route,
      class: "pure-button primary-button icon-button"
    )
  end

  @doc """
  Create floating delete button
  """
  def delete_button(id) do
    HTML.Link.link(
      HTML.raw("<i class='material-icons'>delete</i>"),
      to: "#",
      phx_click: "delete",
      phx_value_id: id,
      class: "pure-button danager-button icon-button",
      data: [confirm: gettext("Are you sure?")]
    )
  end

  @doc """
  Creates floating show button
  """
  def show_button(route) do
    live_redirect(
      HTML.raw("<i class='material-icons'>search</i>"),
      to: route,
      class: "pure-button primary-button icon-button"
    )
  end
end
