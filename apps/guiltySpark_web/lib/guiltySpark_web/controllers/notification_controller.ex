defmodule GuiltySparkWeb.NotificationController do
  use GuiltySparkWeb, :controller

  alias Phoenix.LiveView

  def index(conn, _params) do
    LiveView.Controller.live_render(conn, GuiltySparkWeb.NotificationLiveView, session: %{
      token: "jajajaj", user_id: 2, role_id: 2
    })
  end
end
