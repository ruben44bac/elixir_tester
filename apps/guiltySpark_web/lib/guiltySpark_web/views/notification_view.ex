defmodule GuiltySparkWeb.NotificationView do
  use GuiltySparkWeb, :view

  def render_sections(template, assigns) do
    render(GuiltySparkWeb.NotificationView, template, assigns)
  end
end
