defmodule GuiltySparkWeb.ListView do
  use GuiltySparkWeb, :view

  def render_sections(template, assigns) do
    render(GuiltySparkWeb.ListView, template, assigns)
  end
end
