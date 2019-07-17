defmodule JarvisWeb.Router do
  use JarvisWeb, :router

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_flash
    plug Phoenix.LiveView.Flash
    plug :protect_from_forgery
    plug :put_secure_browser_headers
    plug JarvisWeb.Plugs.SetUser
    plug JarvisWeb.Plugs.SetLocale, default: "en"
  end

  pipeline :api do
    plug :accepts, ["json"]
  end

  scope "/", JarvisWeb do
    pipe_through :browser

    get "/", PageController, :index
    post "/language/:language", PageController, :set_language
    delete "/usergroups/:id/leave", UserGroupController, :leave_group
    resources "/usergroups", UserGroupController
    get "/invitations/:id/accept", InvitationController, :accept
    resources "/invitations", InvitationController
  end

  scope "/shoppinglists", JarvisWeb do
    pipe_through :browser

    get "/open", ShoppingListController, :index_open_lists
    resources "/", ShoppingListController
    live "/:id/items", ItemLive, session: [:user_id , :path_params]
  end

  scope "/auth", JarvisWeb do
    pipe_through :browser

    get "/signout", AuthController, :signout
    get "/:provider", AuthController, :request
    get "/:provider/callback", AuthController, :callback
  end

  scope "/v1/sensors", JarvisWeb do
    pipe_through :api

    get "/devices/external_id/:external_id", DeviceController, :get_by_external_id
    resources "/devices", DeviceController, except: [:new, :edit]
    resources "/measurements", MeasurementController, except: [:new, :edit]
  end

  # Other scopes may use custom stacks.
  # scope "/api", JarvisWeb do
  #   pipe_through :api
  # end
end
