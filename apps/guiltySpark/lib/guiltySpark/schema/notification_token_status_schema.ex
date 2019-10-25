defmodule GuiltySpark.NotificationTokenStatusSchema do
	use Ecto.Schema
	import Ecto.Changeset

	@schema_prefix "notification"
	schema "notification_token_status" do
		field :name, :string
		field :description, :string
		timestamps()
	end

	def changeset(notification_token_status, attrs) do
		notification_token_status
			|> cast(attrs, [:name, :description])
	end
end