defmodule GuiltySpark.NotificationTokenSchema do
	use Ecto.Schema
	import Ecto.Changeset

	@schema_prefix "notification"
	schema "notification_token" do
		field :token, :string
    field :channel_id, :integer
    field :type, :integer
    field :user_id, :integer
		belongs_to :notification_token_status, GuiltySpark.NotificationTokenStatusSchema
		belongs_to :notification, GuiltySpark.NotificationSchema
		timestamps()
	end

	def changeset(notification_token, attrs) do
		notification_token
			|> cast(attrs, [:notification_token_status_id, :token, :channel_id, :type, :user_id, :notification_id])
	end
end
