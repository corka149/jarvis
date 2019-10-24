
defmodule JarvisWeb.ItemController do
  use JarvisWeb, :controller

  action_fallback JarvisWeb.FallbackController

  plug JarvisWeb.Plugs.RequireAuth

end
