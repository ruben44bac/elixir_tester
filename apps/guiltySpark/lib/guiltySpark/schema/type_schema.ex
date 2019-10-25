defmodule GuiltySpark.TypeSchema do
	use Ecto.Schema
	import Ecto.Changeset

	@schema_prefix "notification"
	schema "type" do
		field :name, :string
		field :description, :string

		timestamps()
	end

	def changeset(type, attrs) do
		type
			|> cast(attrs, [:name, :description])
	end
end