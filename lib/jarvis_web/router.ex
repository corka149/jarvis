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
    plug :fetch_flash
    plug :protect_from_forgery
    plug :put_secure_browser_headers
    plug JarvisWeb.Plugs.SetUser
    plug JarvisWeb.Plugs.SetLocale, default: "en"
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

    get "/artworks", ArtworkController, :index_html
    get "/isles", IsleController, :index_html
  end

  # ### ### ### ### ### #
  #          Api        #
  # ### ### ### ### ### #

  scope "/v1/system", JarvisWeb do
    pipe_through :api_without_user

    get "/ready", SystemController, :ready
  end

  scope "/v1", JarvisWeb do
    pipe_through :api

    resources "/artworks", ArtworkController, except: [:new, :edit]
    resources "/isles", IsleController, except: [:new, :edit]
  end
end
