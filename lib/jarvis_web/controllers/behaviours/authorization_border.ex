defmodule JarvisWeb.AuthorizationBorder do
  @moduledoc """
  Defines how to check if an user has access to a resource.
  """

  @callback is_allowed_to_cross?(Map, integer) :: true | false
end
