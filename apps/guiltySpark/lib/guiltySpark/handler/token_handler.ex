defmodule GuiltySpark.TokenHandler do
	alias GuiltySpark.Repo
	alias GuiltySpark.TokenSchema
	alias GuiltySpark.TokenQuery

	def get_token(id) do
		Repo.get(TokenSchema, id)
	end

	def add(command) do
		token = TokenQuery.exist_token(command.token)
			|> Repo.one
		case token do
			nil -> 	new_token(command)
			_ -> validate_user(command, token)
		end
	end

	def total_user() do
		%{total: total} = TokenQuery.total_user()
			|> Repo.one
		total
	end

	def new_token(command) do
		user = TokenQuery.user_token(command.user_id, command.channel_id, command.type)
			|> Repo.one
		case user do
			nil -> 	new_token(command, user)
			%TokenSchema{user_id: 0} -> new_token(command, user)
			_ -> update_token(command, user)
		end
	end

	def new_token(command, _user) do
		add_token_topic(command.token)
		%TokenSchema{}
			|> TokenSchema.changeset(Map.from_struct(command))
			|> Repo.insert
	end

	def validate_user(command, token_user) do
		case (command.user_id == token_user.user_id) do
			true -> {:ok, "El token ya estaba registrado"}
			false -> update_token(command)
				|> dalete_token_user(token_user, command)
		end
	end

	def update_token(command) do
		resp = TokenQuery.user_token(command.user_id, command.channel_id, command.type)
			|> Repo.one
		add_token_topic(command.token)
		if(resp != nil) do
			resp
				|> TokenSchema.changeset(%{token: command.token})
				|> Repo.update
		end
	end

	def update_token(command, user) do
		add_token_topic(command.token)
		user
			|> TokenSchema.changeset(%{token: command.token})
			|> Repo.update
	end

	def dalete_token_user(_params, token_user, command) do
		delete_token_topic(token_user.token)
		token_user
			|> Repo.delete
		add(command)
	end

	def get_user_id(attrs) do
		url = "https://api-test.santiago.mx/json/reply/UsuarioSesionRequest?sesion_id=" <> attrs["sesion_id"]
		response = HTTPoison.get!(url)
		req = Poison.decode!(response.body)
		Map.merge(attrs, req)
	end

	def add_token_topic(token) do

		to = "/topics/general"
		body = Poison.encode!(%{"to" => to,
			registration_tokens: [token]
      })
		HTTPoison.post("https://iid.googleapis.com/iid/v1:batchAdd",
      body,
      %{"Content-Type" => "application/json",
        "Authorization" => "key=AAAA9Ej_qEE:APA91bGbOLmEH3DFWt8mFZpB3nyEOUdmW9CGVl3zr-6ZJotEUihVWlhWeZ8neSzSEyMaeAc9P3lOlUooe74oMBIDrPdd9JRoDLXsDgUzfFSfk1uN_JJskHzf9ZNdBJ_MIYNZO8mKQrs5"}
		)
		#Fcmex.Subscription.subscribe("general", token)
	end

	def delete_token_topic(token) do
		to = "/topics/general"
		body = Poison.encode!(%{"to" => to,
			registration_tokens: [token]
      })
		HTTPoison.post("https://iid.googleapis.com/iid/v1:batchRemove",
      body,
      %{"Content-Type" => "application/json",
        "Authorization" => "key=AAAA9Ej_qEE:APA91bGbOLmEH3DFWt8mFZpB3nyEOUdmW9CGVl3zr-6ZJotEUihVWlhWeZ8neSzSEyMaeAc9P3lOlUooe74oMBIDrPdd9JRoDLXsDgUzfFSfk1uN_JJskHzf9ZNdBJ_MIYNZO8mKQrs5"}
		)
		#Fcmex.Subscription.unsubscribe("general", token)
	end

	def add_token_list_topic(user_id, list_name) do
		resp = get_token_by_user(user_id)
		Task.async(fn ->
			to = "/topics/#{list_name}"
			body = Poison.encode!(%{"to" => to,
				registration_tokens: resp
				})
			HTTPoison.post("https://iid.googleapis.com/iid/v1:batchAdd",
				body,
				%{"Content-Type" => "application/json",
					"Authorization" => "key=AAAA9Ej_qEE:APA91bGbOLmEH3DFWt8mFZpB3nyEOUdmW9CGVl3zr-6ZJotEUihVWlhWeZ8neSzSEyMaeAc9P3lOlUooe74oMBIDrPdd9JRoDLXsDgUzfFSfk1uN_JJskHzf9ZNdBJ_MIYNZO8mKQrs5"}
			)
			#Fcmex.Subscription.subscribe(list_name, resp)
		end)
	end

	def delete_token_list_topic(user_id, list_name) do
		resp = get_token_by_user(user_id)
		to = "/topics/#{list_name}"
			body = Poison.encode!(%{"to" => to,
				registration_tokens: resp
				})
			HTTPoison.post("https://iid.googleapis.com/iid/v1:batchRemove",
				body,
				%{"Content-Type" => "application/json",
					"Authorization" => "key=AAAA9Ej_qEE:APA91bGbOLmEH3DFWt8mFZpB3nyEOUdmW9CGVl3zr-6ZJotEUihVWlhWeZ8neSzSEyMaeAc9P3lOlUooe74oMBIDrPdd9JRoDLXsDgUzfFSfk1uN_JJskHzf9ZNdBJ_MIYNZO8mKQrs5"}
			)
	end

	def get_token_by_user(user_id) do
		TokenQuery.tokens_of_user(user_id)
			|> Repo.all
			|> Enum.map(fn (map) -> map.token end)
	end

	def total_devices() do
		TokenQuery.total_devices()
			|> Repo.all
	end

	def total_token() do
		%{total: total} = TokenQuery.total_token()
			|> Repo.one
		total
	end

	def total_type_user() do
		TokenQuery.total_type_user()
		|> Repo.all
	end

end
