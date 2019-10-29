defmodule GuiltySpark.NotificationQuery do
  import Ecto.Query
  alias GuiltySpark.{
    NotificationSchema,
    NotificationTokenSchema
  }
  def list_notifications(index, size) do
    from n in NotificationSchema,
    select: %{
      id: n.id,
      title: n.title,
      description: n.description,
      image_path: n.image_path,
      date: n.inserted_at
    },
    order_by: [desc: n.id],
    limit: ^size,
    offset: ^index
  end

  def list_notifications(index, size, search) do
    from n in NotificationSchema,
    select: %{
      id: n.id,
      title: n.title,
      description: n.description,
      image_path: n.image_path,
      date: n.inserted_at
    },
    where: like(n.title, ^search),
    order_by: [desc: n.id],
    limit: ^size,
    offset: ^index
  end

  def total_notifications() do
    from n in NotificationSchema,
    select: %{
      total: count(n.id)
    }
  end

  def receiver_total(id) do
    from nt in NotificationTokenSchema,
    where: nt.notification_id == ^id,
    select: %{
      receiver_total: count(nt.id)
    }
  end

  def receiver_by_id(id) do
    from n in NotificationSchema,
    join: nt in NotificationTokenSchema,
    on: n.id == nt.notification_id,
    where: n.id == ^id,
    select: %{
      total: count(nt.id)
    }
  end

  def receiver_channel_by_id(id, channel_id) do
    from n in NotificationSchema,
    join: nt in NotificationTokenSchema,
    on: n.id == nt.notification_id,
    where: n.id == ^id and nt.channel_id == ^channel_id,
    select: %{
      total: count(nt.id)
    }
  end

  def interacion_by_id(id, status_id) do
    from n in NotificationSchema,
    join: nt in NotificationTokenSchema,
    on: n.id == nt.notification_id,
    where: n.id == ^id and nt.notification_token_status_id == ^status_id,
    select: %{
      total: count(nt.id)
    }
  end

  def receiver_interacion_by_id(id, channel_id, status_id) do
    from n in NotificationSchema,
    join: nt in NotificationTokenSchema,
    on: n.id == nt.notification_id,
    where: n.id == ^id and nt.channel_id == ^channel_id and nt.notification_token_status_id == ^status_id,
    select: %{
      total: count(nt.id)
    }
  end

  def receiver_user_by_id(id, user_type)  do
    from n in NotificationSchema,
    join: nt in NotificationTokenSchema,
    on: n.id == nt.notification_id,
    where: n.id == ^id and nt.type == ^user_type,
    select: %{
      total: count(nt.id)
    }
  end

  def last_notification() do
    from n in NotificationSchema,
    order_by: [desc: n.id],
    limit: 1
  end

end
