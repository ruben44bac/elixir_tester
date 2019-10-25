defmodule GuiltySparkWeb.PageController do
  use GuiltySparkWeb, :controller

  alias Phoenix.LiveView

  alias GuiltySpark.PermissionHandler


  def index(conn, _params) do
    valid = PermissionHandler.validate_fluffy(conn.query_params, conn)
    if valid do
      conn
        |> PermissionHandler.validate_session(conn.query_params)
        |> LiveView.Controller.live_render(GuiltySparkWeb.PageLiveView, session: conn.query_params)
    else
      conn
      |> put_session(:token, "")
      |> render(GuiltySparkWeb.ErrorView, "index.html")
    end


  end
end
