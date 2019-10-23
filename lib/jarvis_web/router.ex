defmodule JarvisWeb.Router do
  use JarvisWeb, :router

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_flash
    plug :protect_from_forgery
    plug :put_secure_browser_headers
    plug JarvisWeb.Plugs.SetUser
    plug JarvisWeb.Plugs.SetLocale, default: "en"
  end

  pipeline :api do
    plug :accepts, ["json"]
    plug JarvisWeb.Plugs.SetUser
  end

  # ### ### ### ### ### #
  #        Browser      #
  # ### ### ### ### ### #

  scope "/auth", JarvisWeb do
    pipe_through :browser

    get "/signout", AuthController, :signout
    get "/:provider", AuthController, :request
    get "/:provider/callback", AuthController, :callback
  end

  # ### ### ### ### ### #
  #          Api        #
  # ### ### ### ### ### #

  scope "/v1/sensors", JarvisWeb do
    pipe_through :api

    get "/devices/external_id/:external_id", DeviceController, :get_by_external_id
    resources "/devices", DeviceController, except: [:new, :edit]
    resources "/measurements", MeasurementController, except: [:new, :edit]
  end

  scope "/v1/accounts", JarvisWeb do
    pipe_through :api

    delete "/usergroups/:id/leave", UserGroupController, :leave_group
    resources "/usergroups", UserGroupController, except: [:new, :edit]

    get "/invitations/:id/accept", InvitationController, :accept
    resources "/invitations", InvitationController, except: [:new, :edit, :update, :show]
  end

  scope "/v1/shoppinglists", JarvisWeb do
    pipe_through :api

    get "/open", ShoppingListController, :index_open_lists
    resources "/", ShoppingListController, except: [:new, :edit]
  end

  # Other scopes may use custom stacks.
  # scope "/api", JarvisWeb do
  #   pipe_through :api
  # end
end
