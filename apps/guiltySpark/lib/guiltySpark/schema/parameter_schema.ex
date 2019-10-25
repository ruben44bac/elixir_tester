defmodule GuiltySpark.ParameterSchema do
	use Ecto.Schema
	import Ecto.Changeset

	@schema_prefix "notification"
	schema "parameter" do
		field :name, :string
		field :order, :integer
		field :note, :string

		belongs_to :app_view, GuiltySpark.AppViewSchema
		timestamps()
	end

	def changeset(parameter, attrs) do
		parameter
			|> cast(attrs, [:name, :order, :app_view_id, :note])
	end

end
