defmodule GuiltySparkWeb.NotificationController do
  use GuiltySparkWeb, :controller

  alias Phoenix.LiveView

  def index(conn, _params) do
    LiveView.Controller.live_render(conn, GuiltySparkWeb.NotificationLiveView, session: %{})
  end
end
