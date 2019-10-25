defmodule GuiltySpark.AppViewQuery do
  import Ecto.Query
  alias GuiltySpark.{
    AppViewSchema,
    ParameterSchema
  }

  def name_by_id(id) do
    from av in AppViewSchema,
    where: av.id == ^id,
    select: %{name: av.name},
    limit: 1
  end

  def show_params(id, limit) do
    from p in ParameterSchema,
    where: p.app_view_id == ^id,
    limit: ^limit
  end

end
