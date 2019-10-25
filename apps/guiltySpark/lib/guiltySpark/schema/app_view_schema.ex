defmodule GuiltySpark.AppViewSchema do
	use Ecto.Schema
	import Ecto.Changeset

	@schema_prefix "notification"
	schema "app_view" do
		field :name, :string

		timestamps()
	end

	def changeset(app_view, attrs) do
		app_view
			|> cast(attrs, [:name])
	end
end