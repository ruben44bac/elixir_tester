defmodule GuiltySparkWeb.TokenController do
	use GuiltySparkWeb, :controller
	alias GuiltySpark.TokenHandler
	alias GuiltySpark.AddTokenCommand

	def add(conn, attrs) do
		resp = attrs
			|> TokenHandler.get_user_id
			|> AddTokenCommand.new
			|> TokenHandler.add
		case resp do
      {:ok, _mensaje} -> json conn, %{data: "token registrado"}
			{:error, mensaje} -> json conn, %{error: mensaje}
			_ -> json conn, %{dat: "bien"}
    end
	end
end
