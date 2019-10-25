defmodule GuiltySparkWeb.Router do
  use GuiltySparkWeb, :router

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_flash
    plug Phoenix.LiveView.Flash
    plug :protect_from_forgery
    plug :put_secure_browser_headers
  end

  pipeline :api do
    plug :accepts, ["json"]
  end

  scope "/", GuiltySparkWeb do
    pipe_through :browser

    get "/", PageController, :index
    get "/notification", NotificationController, :index
  end

  # Other scopes may use custom stacks.
  # scope "/api", GuiltySparkWeb do
  #   pipe_through :api
  # end
end
