defmodule GuiltySparkWeb.PageController do
  use GuiltySparkWeb, :controller

  alias Phoenix.LiveView

  def index(conn, _params) do
    LiveView.Controller.live_render(conn, GuiltySparkWeb.GithubDeployView, session: %{})
  end
end
