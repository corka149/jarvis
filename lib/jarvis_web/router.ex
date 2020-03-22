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
    get "/:provider", AuthController, :request
    get "/:provider/callback", AuthController, :callback
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

    resources "/users", UserController, except: [:index, :new, :edit]

    delete "/usergroups/:id/leave", UserGroupController, :leave_group
    resources "/usergroups", UserGroupController, except: [:new, :edit]

    get "/invitations/:id/accept", InvitationController, :accept
    resources "/invitations", InvitationController, except: [:new, :edit, :update, :show]
  end

  scope "/v1/shoppinglists", JarvisWeb do
    pipe_through :api

    get "/open", ShoppingListController, :index_open_lists
    resources "/", ShoppingListController, except: [:new, :edit]
    resources "/:shopping_list_id/items/", ItemController, except: [:new, :edit]
  end

  scope "/v1/finances", JarvisWeb do
    pipe_through :api

    resources "/categories", CategoryController, except: [:new, :edit]
    resources "/transactions", TransactionController, except: [:new, :edit]
  end
end
