defmodule GuiltySparkWeb.NotificationController do
  use GuiltySparkWeb, :controller
  alias GuiltySpark.{
    NotificationHandler,
    PermissionHandler
  }
  alias GuiltySpark.{
    SpecificNewNotificationCommand,
    GenericNewNotificationCommand,
    CheckNotificationCommand
  }
  alias Phoenix.LiveView

  def index(conn, _params) do
    LiveView.Controller.live_render(conn, GuiltySparkWeb.NotificationLiveView, session: PermissionHandler.get_session(conn))
  end

  def new_generic(conn, attrs) do
    resp = attrs
      |> GenericNewNotificationCommand.new
      |> NotificationHandler.send_generic("general")
    case resp do
      {:error, _} -> json conn, %{error: "Algo salio mal"}
      _ -> json conn, %{data: "Tu notificación ha sido enviada"}
    end
  end

  def new_specific(conn, attrs) do
    resp = attrs
      |> SpecificNewNotificationCommand.new
      |> NotificationHandler.send_specific

    case resp do
      {:error, _} -> json conn, %{error: "Algo salio mal"}
      _ -> json conn, %{data: "Tu notificación ha sido enviada"}
    end
  end

  def check(conn, attrs) do
		attrs
		  |> CheckNotificationCommand.new
      |> NotificationHandler.check
    json conn, %{data: "Notificación actualizada"}
	end

end
