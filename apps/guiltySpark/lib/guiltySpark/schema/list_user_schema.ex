defmodule GuiltySpark.ListUserSchema do 
	use Ecto.Schema
	import Ecto.Changeset

	@schema_prefix "notification"
	schema "list_user" do 
		field :user_id, :integer
		belongs_to :list, GuiltySpark.ListSchema

		timestamps()
	end

	def changeset(list_user, attrs) do
		list_user
			|> cast(attrs, [:user_id, :list_id])
	end
end