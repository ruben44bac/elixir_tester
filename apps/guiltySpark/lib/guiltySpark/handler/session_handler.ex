defmodule GuiltySpark.PermissionHandler do


  def validate_fluffy(params, conn) do

    case params == %{} do
       true -> Plug.Conn.get_session(conn, :token)
       |> validate_fluffy
       false -> validate_fluffy(params)
    end
  end

  def validate_fluffy(%{"token" => token }), do: validate_fluffy(token)

  def validate_fluffy(token) do
    req = JSX.encode! %{"token" => token}
    case HTTPoison.post("http://10.0.3.120:4000/api/login/verify", req, [{"Content-Type", "application/json"}]) do
      {:ok, %HTTPoison.Response{status_code: 200}} ->
        true
      {:ok, _} ->
        false
      {:error, _} ->
        false
    end
  end

  def validate_session(conn, %{"uid" => user_id, "rid" => role_id, "token" => token}) do
    conn
      |>  Plug.Conn.put_session(:user_id, user_id)
      |>  Plug.Conn.put_session(:role_id, role_id)
      |>  Plug.Conn.put_session(:token, token)
  end

  def validate_session(conn, _params), do: conn

  def events_permision(token,
    role_id,
    user_id,
    program) do
      system = "notificacion_digital"
      req = %{"system" => Base.encode64(system),
        "role_id" => role_id,
        "user_id" => user_id,
        "token" => token,
        "path" => Base.encode64(program)}

      HTTPoison.get("http://10.0.3.120:4000/api/permission", [], params: req)
        |> IO.inspect(label: "RESPUESTA DE SERVICIO DEL PEDRON =============>>>>>    ")

      case HTTPoison.get("http://10.0.3.120:4000/api/permission", [], params: req) do
        {:ok, %HTTPoison.Response{status_code: 200, body: body}} ->
          body
           |> String.replace("'", "\"")
           |> Poison.decode!
        {:ok, _} -> %{}
        {:error, _} -> %{}
      end
  end

  def get_session(conn) do
    user_id = Plug.Conn.get_session(conn, :user_id)
    role_id = Plug.Conn.get_session(conn, :role_id)
    token = Plug.Conn.get_session(conn, :token)
    %{user_id: user_id, role_id: role_id, token: token}
  end

end
