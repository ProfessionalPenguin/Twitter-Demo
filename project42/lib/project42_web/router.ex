defmodule Project42Web.Router do
  use Project42Web, :router

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_flash
    plug :protect_from_forgery
    plug :put_secure_browser_headers
    plug Project42Web.Auth
  end

  pipeline :api do
    plug :accepts, ["json"]
  end

  scope "/", Project42Web do
    pipe_through :browser

    resources "/users", UserController, only: [:index, :show, :new, :create]
    resources "/sessions", SessionController, only: [:new, :create, :delete]
    get "/", PageController, :index
  end

  # Other scopes may use custom stacks.
  # scope "/api", Project42Web do
  #   pipe_through :api
  # end
end
