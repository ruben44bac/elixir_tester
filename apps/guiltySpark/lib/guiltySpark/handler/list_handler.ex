defmodule GuiltySpark.ListHandler do
  alias GuiltySpark.Repo
  alias GuiltySpark.ListQuery
  alias GuiltySpark.{
    TokenHandler,
    NotificationHandler
  }
  alias GuiltySpark.{
    ListSchema,
    ListUserSchema
  }

  def get(id) do
    Repo.get(ListSchema, id)
  end

  def list(index) do
    ListQuery.list_user_count(index, 10)
      |> Repo.all()
  end

  def total() do
    total = ListQuery.total_list()
      |> Repo.one()
    total.total
  end

  def users_for_list(id) do
    ListQuery.users_for_list(id)
      |> Repo.all
  end

  def left_users_for_list(id) do
    {:ok, result} = ListQuery.left_users_for_list(id)
      |>Repo.query
    sql_query_to_map(result)
  end

  def sql_query_to_map(attrs) do
    columns = attrs.columns |> Enum.map(&(String.to_atom(&1)))
    Enum.map attrs.rows, fn(row) ->
      Enum.zip(columns, row) |> Map.new
    end
  end

  def add_user(user_id, list_id) do
    TokenHandler.add_token_list_topic(user_id, get(list_id).name)
    %ListUserSchema{}
      |> ListUserSchema.changeset(%{ user_id: user_id, list_id: list_id})
      |> Repo.insert
  end

  def delete_user(id, user_id, list_id) do
    TokenHandler.delete_token_list_topic(user_id, get(list_id).name)
    Repo.get(ListUserSchema, id)
    |> Repo.delete
  end

  def update_count_user(list_id, list) do
    resp = ListQuery.user_count_by_id(list_id)
      |> Repo.one
    Enum.map(list, fn (map) ->
      case map.id == list_id do
        true -> map
          |> Map.put(:users_count, resp.users_count)
        false -> map
      end
    end)
  end

  def add_status(list) do
    Enum.map(list, fn (map) ->
        map
          |> Map.put(:status, true)
    end)
  end

  def change_status(id, list) do
    Enum.map(list, fn (map) ->
      case map.id == id do
        true ->  map
        |> Map.put(:status, !map.status)
        false -> map
      end
    end)
  end

  def get_list_name(id) do
    get(id).name
  end

  def concat_list(name, list) do
    res = List.myers_difference(list, [name])
      |> List.keyfind(:eq, 0)
    case res do
      nil -> List.insert_at(list, 0, name)
      _ -> List.delete(list, name)
    end
  end

  def tokens_distinct_between_list([head | tail], params, req) do
    if params == "" do
      tokens_distinct_between_list(tail, "l.name = '#{head}'", req)
    else
      tokens_distinct_between_list(tail, "#{params} or l.name = '#{head}'", req)
    end
  end

  def tokens_distinct_between_list([], params, req) do
    {:ok, result} = ListQuery.tokens_distinct_between_list(params)
      |> Repo.query
    tester = req
      |> NotificationHandler.upload_image
      |> NotificationHandler.get_name_view
      |> NotificationHandler.build_json
      |> NotificationHandler.save_notification
    Task.async(fn ->
			result
        |> sql_query_to_map
        |> NotificationHandler.send_specific_token(req, tester)
		end)
  end

  def create_list(params) do
    params
      |> Repo.insert
  end

  def delete_list(id) do
    get(id)
      |> Repo.delete
  end
end
