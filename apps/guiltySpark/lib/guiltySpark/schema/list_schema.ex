defmodule GuiltySpark.ListSchema do
	use Ecto.Schema
	import Ecto.Changeset

	@schema_prefix "notification"
	schema "list" do
		field :name, :string
		field :topic, :string

		timestamps()
	end

	def changeset(list, attrs) do
		list
			|> cast(attrs, [:name])
			|> validate_required([:name], message: "Ingresa este dato, es requerido")
			|> validate_length(:name, max: 100, message: "Debe de ser menor a 100 caracteres")
			|> validate_length(:name, min: 2, message: "Debe de ser mayor a 2 caracteres")
			|> unique_constraint(:name, message: "Ya existe una lista con este nombre")
	end
end
