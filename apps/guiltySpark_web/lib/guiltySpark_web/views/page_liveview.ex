defmodule GuiltySparkWeb.PageLiveView do
  use Phoenix.LiveView
  alias GuiltySpark.{
    NotificationHandler,
    ListHandler,
    TokenHandler,
    NotificationDetailHandler
  }

  def render(assigns) do
    render_index(assigns)
  end

  def mount(session, socket) do
    {:ok, assign(socket, session)}
  end

  defp render_index(assigns) do
    resp = %{
      notification_total: NotificationHandler.total(),
      list_total: ListHandler.total(),
      user_total: TokenHandler.total_user(),
      last_notification: last_notification(),
      total_devices: TokenHandler.total_devices(),
      total_token: TokenHandler.total_token(),
      total_type_user: TokenHandler.total_type_user()
    }
    GuiltySparkWeb.PageView.render("index.html", assigns |> Map.merge(resp))
  end

  defp last_notification() do
    last = NotificationDetailHandler.last_notification()
    NotificationDetailHandler.detail(
      last
        |> Map.put(:date, last.updated_at)
      )
  end
end
