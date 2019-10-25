defmodule GuiltySparkWeb.PageController do
  use GuiltySparkWeb, :controller

  def index(conn, _params) do
    render(conn, "index.html")
  end
end
