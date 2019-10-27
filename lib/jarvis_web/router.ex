defmodule JarvisWeb.Router do
  use JarvisWeb, :router

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_flash
    plug :protect_from_forgery
    plug :put_secure_browser_headers
    plug JarvisWeb.Plugs.SetUser
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
    resources "/:shopping_list_id/items/", ItemController, except: [:new, :edit]
  end

  scope "/v1/finances", JarvisWeb do
    pipe_through :api

    resources "/categories", CategoryController, except: [:new, :edit]
  end
end
