defmodule GuiltySparkWeb.LayoutView do
  use GuiltySparkWeb, :view
  alias GuiltySpark.PermissionHandler

  def user_email(_conn) do
    "rubeng44@hotmail.com"
  end

  def valid_session(conn) do
    PermissionHandler.validate_fluffy(conn.query_params, conn)
  end

end
