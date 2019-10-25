defmodule GuiltySparkWeb.PageLiveView do
  use Phoenix.LiveView

  def render(assigns) do
    GuiltySparkWeb.PageView.render("github_deploy.html", assigns)
  end

  def mount(_session, socket) do
    {:ok, assign(socket, deploy_step: "Ready!")}
  end

  def handle_event("github_deploy", _value, socket) do
    # do the deploy process
    {:noreply, assign(socket, deploy_step: "Starting deploy...")}
  end
end
