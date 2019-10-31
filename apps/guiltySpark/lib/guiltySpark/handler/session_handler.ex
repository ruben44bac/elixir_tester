defmodule GuiltySpark.PermissionHandler do

  @fluffy_ip "10.0.3.120"
  #@fluffy_ip "172.19.1.1"
  def validate_fluffy(params, conn) do

    keys = Map.keys(params)
    case keys != ["rid", "token", "uid"] do
      true -> Plug.Conn.get_session(conn, :token)
       |> validate_fluffy
       false -> validate_fluffy(params)
    end
  end

  def validate_fluffy(%{"token" => token }), do: validate_fluffy(token)

  def validate_fluffy(token) do
    req = JSX.encode! %{"token" => token}
    case HTTPoison.post("http://#{@fluffy_ip}:4000/api/login/verify", req, [{"Content-Type", "application/json"}]) do
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

      case HTTPoison.get("http://#{@fluffy_ip}:4000/api/permission", [], params: req) do
        {:ok, %HTTPoison.Response{status_code: 200, body: body}} ->
          body
           |> String.replace("'", "\"")
           |> Poison.decode!
        {:ok, _} -> %{}
        {:error, _} -> %{}
      end
  end


  def get_user_names(params, conn, _attrs) do
    keys = Map.keys(params)
    case keys != ["rid", "token", "uid"] do
        true -> Plug.Conn.get_session(conn, :user_id)
            |> get_user_names(Plug.Conn.get_session(conn, :role_id))
        false -> get_user_names(params)
    end
  end

  def get_user_names(%{"uid" => user_id, "rid" => role_id }), do: get_user_names(user_id, role_id)

  def get_user_names(user_id, role_id) do
    req = %{"user_id" => user_id}
    case HTTPoison.get("http://#{@fluffy_ip}:4000/api/roles/id", [], params: req) do
      {:ok, %HTTPoison.Response{status_code: 200, body: body}} ->
        body
         |> String.replace("'", "\"")
         |> Poison.decode!
         |> select_user(role_id)
      {:ok, _} -> %{}
      {:error, _} -> %{}
    end
  end

  def select_user(%{"data" => %{"roles" => roles}}, role_id) do
    roles_array(roles, String.to_integer(role_id))
  end

  def roles_array([head | teal], role_id) do
    if head["role_id"] == role_id do
      %{name: head["user_name"], role: head["description"]}
    else
      roles_array(teal, role_id)
    end
  end

  def roles_array([], _role_id), do: nil

  def get_session(conn) do
    user_id = Plug.Conn.get_session(conn, :user_id)
    role_id = Plug.Conn.get_session(conn, :role_id)
    token = Plug.Conn.get_session(conn, :token)
    %{user_id: user_id, role_id: role_id, token: token}
  end

end
