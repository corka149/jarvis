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
    resources "/:shopping_list_id/items", ItemController, except: [:show]
  end

  scope "/animalxing", JarvisWeb do
    pipe_through :browser

    # Isles
    live "/isles", IsleLive.Index, :index
    live "/isles/new", IsleLive.Index, :new
    live "/isles/:id/edit", IsleLive.Index, :edit
    live "/isles/:id", IsleLive.Show, :show

    # Artworks
    live "/artworks", ArtworkLive.Index, :index
    live "/artworks/new", ArtworkLive.Index, :new
    live "/artworks/:id/edit", ArtworkLive.Index, :edit

    live "/artworks/:id", ArtworkLive.Show, :show
    live "/artworks/:id/show/edit", ArtworkLive.Show, :edit
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

  scope "/v1/animalxing", JarvisWeb do
    pipe_through :api

    resources "/isles", IsleApiController, except: [:new, :edit]
    resources "/isles/:belongs_to/artworks", ArtworkApiController, except: [:new, :edit]
  end
end
