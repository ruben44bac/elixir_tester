defmodule GuiltySpark.NotificationListSchema do
	use Ecto.Schema
	import Ecto.Changeset

	@schema_prefix "notification"
	schema "notification_list" do
		belongs_to :list, GuiltySpark.ListSchema
		belongs_to :notification, GuiltySpark.NotificationSchema
	end

	def changeset(notification_list, attrs) do
		notification_list
			|> cast(attrs, [:list_id, :notification_id])
	end
end