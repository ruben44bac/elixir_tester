defmodule GuiltySpark.TokenQuery do
	import Ecto.Query
	alias GuiltySpark.{
		TokenSchema,
		ChannelSchema
	}

	def exist_token(token) do
		from t in TokenSchema,
		where: t.token == ^token,
		limit: 1
	end

	def user_token(user_id, channel_id, type) do
		from t in TokenSchema,
		where: t.user_id == ^user_id and t.channel_id == ^channel_id and t.type == ^type,
		limit: 1
	end

	def tokens_of_user(user_id) do
		from t in TokenSchema,
		where: t.user_id == ^user_id
	end

	def total_user() do
		from t in TokenSchema,
		select: %{
      total: count(fragment("DISTINCT ?", t.user_id))
		}
	end

	def total_devices() do
    from c in ChannelSchema,
    join: t in TokenSchema,
		on: c.id == t.channel_id,
		select: %{
			count: count(t.channel_id),
			name: c.name
		},
		group_by: [t.channel_id, c.name]
	end

	def total_token() do
		from t in TokenSchema,
		select: %{
			total: count(t.id)
		}
	end

	def total_type_user() do
		from t in TokenSchema,
		select: %{
			count: count(fragment("DISTINCT ?", t.user_id)),
			type: t.type
		},
		group_by: [t.type]

	end

end
