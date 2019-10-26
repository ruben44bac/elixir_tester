defmodule GuiltySparkWeb.LayoutView do
  use GuiltySparkWeb, :view
  alias GuiltySpark.PermissionHandler

  def user_email(conn) do
    %{name: name} = PermissionHandler.get_user_names(conn.query_params, conn, "")
    name
  end

  def user_role(conn) do
    %{role: role} = PermissionHandler.get_user_names(conn.query_params, conn, "")
    role
  end

  def valid_session(conn) do
    PermissionHandler.validate_fluffy(conn.query_params, conn)
  end

end
