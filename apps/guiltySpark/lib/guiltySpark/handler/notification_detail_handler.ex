defmodule GuiltySpark.NotificationDetailHandler do
  alias GuiltySpark.Repo
  alias GuiltySpark.{
    NotificationSchema,
    AppViewSchema
  }
  alias GuiltySpark.{
    NotificationQuery,
    AppViewQuery
  }

  def detail(notifiation) do
    %{
      id: notifiation.id,
      image: notifiation.image_path,
      title: notifiation.title,
      description: notifiation.description,
      date: notifiation.date,
      receiver_total: receiver_total(notifiation.id),
      receiver_web: receiver_channel(notifiation.id, 1),
      receiver_ios: receiver_channel(notifiation.id, 2),
      receiver_android: receiver_channel(notifiation.id, 3),
      interaction_true: interactions(notifiation.id, 2),
      interaction_false: interactions(notifiation.id, 1),
      receiver_interaction_web: receiver_interacion(notifiation.id, 1),
      receiver_interaction_ios: receiver_interacion(notifiation.id, 2),
      receiver_interaction_android: receiver_interacion(notifiation.id, 3),
      receiver_user: receiver_user(notifiation.id, 1),
      receiver_guess: receiver_user(notifiation.id, 2),
      receiver_x: receiver_user(notifiation.id, 0),
    }
  end

  def detail(%{id: id}, _params) do
    resp = NotificationSchema
      |> Repo.get(id)

    detail(%{
        image_path: resp.image_path,
        title: resp.title,
        description: resp.description,
        date: resp.inserted_at,
        id: resp.id
      })
  end

  def receiver_total(id) do
    NotificationQuery.receiver_by_id(id)
      |> Repo.one
      |> Map.get(:total)
  end
  def receiver_channel(id, channel_id) do
    NotificationQuery.receiver_channel_by_id(id, channel_id)
    |> Repo.one
    |> Map.get(:total)
  end
  def interactions(id, type) do
    NotificationQuery.interacion_by_id(id, type)
      |> Repo.one
      |> Map.get(:total)
  end
  def receiver_interacion(id, channel_id) do
    NotificationQuery.receiver_interacion_by_id(id, channel_id, 2)
      |> Repo.one
      |> Map.get(:total)
  end
  def receiver_user(id, type) do
    NotificationQuery.receiver_user_by_id(id, type)
      |> Repo.one
      |> Map.get(:total)
  end
  def app_view() do
    Repo.all(AppViewSchema)
  end
  def app_view_show_params(id) do
    resp = AppViewQuery.show_params(id, 1)
      |> Repo.one
    case resp do
      nil -> false
      _ -> true
    end
  end
  def app_view_params(id) do
    AppViewQuery.show_params(id, 2)
      |> Repo.all
  end

  def last_notification() do
    NotificationQuery.last_notification()
      |> Repo.one
  end
end
