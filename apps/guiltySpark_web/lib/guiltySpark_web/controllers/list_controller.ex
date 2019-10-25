defmodule GuiltySparkWeb.ListController do
  use GuiltySparkWeb, :controller

  alias Phoenix.LiveView

  alias GuiltySpark.PermissionHandler


  def index(conn, _params) do
    LiveView.Controller.live_render(conn, GuiltySparkWeb.ListLiveView,
    session: PermissionHandler.get_session(conn)
      |> Map.merge(%{path: conn.request_path}))
  end

end
