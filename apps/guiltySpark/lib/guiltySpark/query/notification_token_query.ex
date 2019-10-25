defmodule GuiltySpark.NotificationTokenQuery do
  import Ecto.Query
  alias GuiltySpark.{
    TokenSchema,
    NotificationTokenSchema
  }

  def generic_notification_token(id) do
    from t in TokenSchema,
    select: %{
      notification_token_status_id: 1,
      token: t.token,
      channel_id: t.channel_id,
      type: t.type,
      user_id: t.user_id,
      notification_id: fragment("CAST(? AS INTEGER)", ^id),
      inserted_at: type(fragment("now()"), :naive_datetime),
      updated_at: type(fragment("now()"), :naive_datetime)
    }
  end

  def token_notification(notification_id, token) do
    from n in NotificationTokenSchema,
    where: n.notification_id == ^notification_id and n.token == ^token,
    order_by: [desc: n.id],
    limit: 1
  end
end
