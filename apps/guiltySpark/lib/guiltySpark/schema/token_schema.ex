defmodule GuiltySpark.TokenSchema do
	use Ecto.Schema
	import Ecto.Changeset

	@schema_prefix "notification"
	schema "token" do
		field :token, :string
		field :user_id, :integer
		field :type, :integer
		field :name, :string
		field :email, :string

		belongs_to :channel, GuiltySpark.ChannelSchema
		timestamps()
	end

	def changeset(token, attrs) do
		token
			 |> cast(attrs, [:token, :user_id, :channel_id, :type, :name, :email])
	end

end
