defmodule GuiltySpark.NotificationHandler do
  alias GuiltySpark.Repo
  alias GuiltySpark.{
    AppViewQuery,
    NotificationTokenQuery,
    TokenQuery,
    NotificationQuery
  }
  alias GuiltySpark.{
    NotificationSchema,
    NotificationTokenSchema
  }
  alias GuiltySpark.ListHandler
  alias GuiltySpark.{
    GenericNewNotificationCommand,
    SpecificNewNotificationCommand
  }

  @topic_check "check"

  def send_generic(command, topic) do
    command
      |> upload_image
      |> get_name_view
      |> send_token_topic(topic)
      |> save_notification
      |> insert_token_send(topic)
  end

  def send_specific(command) do
    command
      |> upload_image
      |> get_name_view
      |> build_json
      |> save_notification
      |> get_tokens_user(command)
  end

  def upload_image(command) do
    url = "https://api-test.santiago.mx/json/reply/NotificacionImagenRequest"
    body = Poison.encode!(%{"base64" => command.image_path})
    {:ok, response} = HTTPoison.post(url, body, %{"Content-Type" => "application/json"})
    req = Poison.decode!(response.body)
    command
      |> Map.put(:image_path, req["name"])
  end

  def get_name_view(command) do
    res = AppViewQuery.name_by_id(command.app_view_id)
      |> Repo.one
    command
      |> Map.put(:app_view, res.name)
  end

  def build_json(command) do
    notif = struct_notification_request(command)
    dat = struct_data_request(command)
    to = command.user_id
    command
      |> Map.put(:json, struct_json_notification(notif, dat, to))
  end

  def get_tokens_user(attrs, command) do
    TokenQuery.tokens_of_user(command.user_id)
      |> Repo.all
      |> send_specific_token(command, attrs)
  end

  def send_specific_token([head | tail], command, attrs) do
    merge = command
    |> Map.merge(attrs)
    notif = struct_notification_request(merge)
    dat = struct_data_request(merge)
    to = head.token
    body = Poison.encode!(%{"to" => to,
      notification: notif,
      data: dat
      })

    HTTPoison.post("https://fcm.googleapis.com/fcm/send",
      body,
      %{"Content-Type" => "application/json",
        "Authorization" => "key=AAAA9Ej_qEE:APA91bGbOLmEH3DFWt8mFZpB3nyEOUdmW9CGVl3zr-6ZJotEUihVWlhWeZ8neSzSEyMaeAc9P3lOlUooe74oMBIDrPdd9JRoDLXsDgUzfFSfk1uN_JJskHzf9ZNdBJ_MIYNZO8mKQrs5"}
    )
    # Fcmex.push(to,
    #   notification: notif,
    #   data: dat )
    insert_one_token_send(merge.id, head.token, head.channel_id, head.type, head.user_id)
    send_specific_token(tail, command, attrs)
  end

  def send_specific_token([], _command, _attrs), do: nil

  def send_token_topic(command, topic) do
    notif = struct_notification_request(command)
    dat = struct_data_request(command)
    to = "/topics/#{topic}"
    body = Poison.encode!(%{"to" => to,
      notification: notif,
      data: dat
      })
    HTTPoison.post("https://fcm.googleapis.com/fcm/send",
      body,
      %{"Content-Type" => "application/json",
        "Authorization" => "key=AAAA9Ej_qEE:APA91bGbOLmEH3DFWt8mFZpB3nyEOUdmW9CGVl3zr-6ZJotEUihVWlhWeZ8neSzSEyMaeAc9P3lOlUooe74oMBIDrPdd9JRoDLXsDgUzfFSfk1uN_JJskHzf9ZNdBJ_MIYNZO8mKQrs5"}
    )
    #IO.inspect(test, label: "JAJAJAJAJAJAJA =======>> ")
    # Fcmex.push(to,
    #   notification: notif,
    #   data: dat )
    command
      |> Map.put(:json, struct_json_notification(notif, dat, to))
  end

  def struct_notification_request(command) do
    %{
      title: command.title,
      body: command.description,
      icon: command.image_path,
      sound: "default",
      mutable_content: true,
      click_action: "Principal",
      image: command.image_path
    }
  end

  def struct_data_request(command) do
    %{
      id: get_last_id().id + 1,
      image: command.image_path,
      parametros: command.parameters,
      view: command.app_view,
      link: command.link
    }
  end

  def struct_json_notification(notification, data, to) do
    Poison.encode!(%{
      to: to,
      notification: notification,
      data: data
    })
  end

  def save_notification(command) do
    {:ok, notification_inserted} = %NotificationSchema{}
      |> NotificationSchema.changeset(Map.from_struct(command))
      |> Repo.insert

    notification_inserted
      |> Map.merge(%{app_view: command.app_view})
  end

  def insert_token_send(attrs, topic) do
    list = case topic do
      "general" -> insert_general_topic(attrs)
      _ -> insert_topic(attrs, topic)
    end
    NotificationTokenSchema
      |> Repo.insert_all(list)
  end

  def insert_general_topic(attrs) do
    NotificationTokenQuery.generic_notification_token(attrs.id)
      |> Repo.all
  end

  def insert_topic(attrs, topic) do
    NotificationTokenQuery.topic_notification_token(attrs.id, topic)
      |> Repo.all
  end

  def insert_one_token_send(notification_id, token, channel_id, type, user_id) do
    %NotificationTokenSchema{}
      |> NotificationTokenSchema.changeset(%{notification_token_status_id: 1,
          token: token,
          channel_id: channel_id,
          type: type,
          user_id: user_id,
          notification_id: notification_id})
      |> Repo.insert
  end

  def check(attrs) do
    resp = NotificationTokenQuery.token_notification(attrs.id, attrs.token)
      |> Repo.one
    if(resp != nil) do
      resp
        |> NotificationTokenSchema.changeset(%{notification_token_status_id: 2})
        |> Repo.update
      GuiltySparkWeb.Endpoint.broadcast_from(self(), @topic_check, "check", %{id: attrs.id})
    end
  end

  # live

  def list(index, %{search: search}) do
    sear = search
      |> String.replace(" ", "%")
    NotificationQuery.list_notifications(index, 10, "%" <> sear <> "%")
      |> Repo.all()
  end

  def list(index, _search) do
    NotificationQuery.list_notifications(index, 10)
      |> Repo.all()
  end

  def total() do
    total = NotificationQuery.total_notifications()
      |> Repo.one()
    total.total
  end

  def generic_send(socket) do
    req = %{
      title: socket.assigns.new_conf.form.title,
      description: socket.assigns.new_conf.form.description,
      image_path: socket.assigns.new_conf.form.image,
      app_view_id: socket.assigns.new_conf.form.app_view.app_view_id,
      parameters:
      %{
        p1: socket.assigns.new_conf.form.app_view.p1,
        p2: socket.assigns.new_conf.form.app_view.p2
      },
      link: socket.assigns.new_conf.form.link_web,
      channel_id: 4,
      type_id: socket.assigns.new_conf.form.type
    }
      |> GenericNewNotificationCommand.new
    send_generic(req, "general")
  end

  def list_send(socket) do
    req = %{
      title: socket.assigns.new_conf.form.title,
      description: socket.assigns.new_conf.form.description,
      image_path: socket.assigns.new_conf.form.image,
      app_view_id: socket.assigns.new_conf.form.app_view.app_view_id,
      parameters:
      %{
        p1: socket.assigns.new_conf.form.app_view.p1,
        p2: socket.assigns.new_conf.form.app_view.p2
      },
      link: socket.assigns.new_conf.form.link_web,
      channel_id: 4,
      type_id: socket.assigns.new_conf.form.type,
      user_id: 0
    }
      |> SpecificNewNotificationCommand.new
    if Enum.count(socket.assigns.new_conf.form.app_view.list_selected) > 1 do
      ListHandler.tokens_distinct_between_list(socket.assigns.new_conf.form.app_view.list_selected, "", req)
    else
      topic = List.first(socket.assigns.new_conf.form.app_view.list_selected)
      send_generic(req, topic)
    end
  end

  def form_validate(step, form) do
    case step do
      2 -> validate_first_form(step, form)
      3 -> validate_all_form(step, form)
      _ -> step
    end
  end

  defp validate_first_form(step, form) do
    resp = %NotificationSchema{}
      |> NotificationSchema.changeset_first(%{
        image_path: form.image,
        title: form.title,
        description: form.description,
      })
    case resp.valid? && (form.type != 2 || (form.type == 2 && form.app_view.list_selected != [])) do
      true -> step
      _ -> 1
    end
  end

  defp validate_all_form(step, form) do
    resp = %NotificationSchema{}
      |> NotificationSchema.changeset(%{
        image_path: form.image,
        title: form.title,
        description: form.description,
        link: form.link_web,
        app_view_id: form.app_view.app_view_id,
        json: "{}",
        channel_id: 4,
        type_id:  form.type
      })
    case resp.valid? do
      true -> step
      _ -> step - 1
    end
  end

  defp get_last_id do
    NotificationQuery.last_notification()
      |> Repo.one
  end

end
