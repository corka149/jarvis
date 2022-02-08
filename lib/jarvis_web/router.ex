defmodule JarvisWeb.Router do
  use JarvisWeb, :router

  pipeline :api do
    plug :accepts, ["json"]
    plug JarvisWeb.Plugs.SetUser
  end

  pipeline :api_without_user do
    plug :accepts, ["json"]
  end

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_live_flash
    plug :protect_from_forgery
    plug :put_secure_browser_headers
    plug JarvisWeb.Plugs.SetUser
    plug JarvisWeb.Plugs.SetLocale, default: "en"
    plug :put_root_layout, {JarvisWeb.LayoutView, :root}
  end

  # ### ### ### ### ### #
  #          HTML       #
  # ### ### ### ### ### #

  scope "/", JarvisWeb do
    pipe_through :browser

    get "/", PageController, :index
  end

  scope "/auth", JarvisWeb do
    pipe_through :browser

    get "/signin", AuthController, :signin
    post "/signin", AuthController, :signin_by_jarvis
    get "/signout", AuthController, :signout
  end

  scope "/accounts", JarvisWeb do
    pipe_through :browser

    resources "/user", UserController, only: [:show, :edit, :update, :delete], singleton: true

    delete "/usergroups/:id/leave", UserGroupController, :leave_group
    resources "/usergroups", UserGroupController

    get "/invitations/:id/accept", InvitationController, :accept
    resources "/invitations", InvitationController, except: [:edit, :update, :show]
  end

  scope "/shoppinglists", JarvisWeb do
    pipe_through :browser

    get "/open", ShoppingListController, :index_open_lists
    resources "/", ShoppingListController
    resources "/:shopping_list_id/items", ProductController, except: [:show]
  end

  scope "/inventory", JarvisWeb do
    pipe_through :browser

    # Places
    live "/places", PlaceLive.Index, :index
    live "/places/new", PlaceLive.Index, :new
    live "/places/:id/edit", PlaceLive.Index, :edit
    live "/places/:id", PlaceLive.Show, :show

    # Items
    live "/items", ItemLive.Index, :index
    live "/items/new", ItemLive.Index, :new
    live "/items/:id/edit", ItemLive.Index, :edit

    live "/items/:id", ItemLive.Show, :show
    live "/items/:id/show/edit", ItemLive.Show, :edit
  end

  # ### ### ### ### ### #
  #          Api        #
  # ### ### ### ### ### #

  scope "/v1/system", JarvisWeb do
    pipe_through :api_without_user

    get "/ready", SystemController, :ready
  end

  scope "/v1/accounts", JarvisWeb do
    pipe_through :api

    get "/usergroups", UserGroupApiController, :index
  end

  scope "/v1/inventory", JarvisWeb do
    pipe_through :api

    resources "/places", PlaceApiController, except: [:new, :edit]
    resources "/places/:belongs_to/items", ItemApiController, except: [:new, :edit]
  end
end
