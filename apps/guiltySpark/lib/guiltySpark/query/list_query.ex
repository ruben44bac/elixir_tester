defmodule GuiltySpark.ListQuery do
  import Ecto.Query
  alias GuiltySpark.{
    ListSchema,
    ListUserSchema,
    TokenSchema
  }

  def list_user_count(index, size) do
    from l in ListSchema,
    select: %{
      id: l.id,
      name: l.name,
      users_count: fragment("select count(distinct lu.user_id) as n from notification.list_user lu, notification.token t where list_id = ? and lu.user_id = t.user_id", l.id)
    },
    order_by: [desc: l.id],
    limit: ^size,
    offset: ^index
  end

  def user_count_by_id(id) do
    from l in ListSchema,
    select: %{
      id: l.id,
      name: l.name,
      users_count: fragment("select count(distinct lu.user_id) as n from notification.list_user lu, notification.token t where list_id = ? and lu.user_id = t.user_id", l.id)
    },
    where: l.id == ^id
  end

  def total_list() do
    from l in ListSchema,
    select: %{
      total: count(l.id)
    }
  end

  def users_for_list(list_id) do
    from lu in ListUserSchema,
    join: t in TokenSchema,
    on: lu.user_id == t.user_id,
    where: lu.list_id == ^list_id,
    select: %{
      id: lu.id,
      user_id: lu.user_id,
      web: fragment("select count(id) from notification.token where channel_id = 1 and user_id = ? ", lu.user_id),
      android: fragment("select count(id) from notification.token where channel_id = 3 and user_id = ? ", lu.user_id),
      ios: fragment("select count(id) from notification.token where channel_id = 2 and user_id = ? ", lu.user_id),
      name: t.name,
      email: t.email
    },
    order_by: [desc: lu.id],
    group_by: [lu.user_id, t.name, t.email, lu.id]
  end

  def left_users_for_list(id) do
    """
    SELECT f1.user_id,
    (select count(id) from notification.token where channel_id = 1 and user_id = f1.user_id ) as web,
    (select count(id) from notification.token where channel_id = 3 and user_id = f1.user_id ) as android,
    (select count(id) from notification.token where channel_id = 2 and user_id = f1.user_id ) as ios,
    f1.name, f1.email, f1.rank
    FROM  (select user_id, token, name, email, rank() over (partition by user_id order by id desc) as rank from notification.token) AS f1
    LEFT OUTER JOIN (select user_id from notification.list_user where list_id = #{id}) AS l0
    ON l0.user_id = f1.user_id
    where (l0.user_id IS NULL) and f1.rank = 1
    """
  end

  def tokens_distinct_between_list(condition) do
    """
    select distinct t.token, t.channel_id, t.type, t.user_id from notification.token t
    inner join notification.list_user lu on lu.user_id = t.user_id
    inner join notification.list l on lu.list_id = l.id
    where #{condition}
    """
  end
end
