defmodule GuiltySparkWeb.NotificationLiveView do
  use Phoenix.LiveView

  def render(assigns) do
    GuiltySparkWeb.NotificationView.render("notification.html", assigns)
  end

  def mount(_session, socket) do
    {:ok, assign(socket, deploy_step: "Ready!")}
  end

  def handle_event("github_deploy", _value, socket) do
    # do the deploy process
    {:noreply, assign(socket, deploy_step: "Starting deploy...")}
  end
end


defmodule GuiltySparkWeb.NotificationView do
  use GuiltySparkWeb, :view
end
