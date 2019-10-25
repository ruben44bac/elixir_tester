defmodule GuiltySparkWeb.LayoutView do
  use GuiltySparkWeb, :view

  def user_email(_conn) do
    "rubeng44@hotmail.com"
  end

  def valid_session(conn) do
    true
  end

end
