defmodule GuiltySparkWeb.NotificationLiveView do
  use Phoenix.LiveView

  alias GuiltySpark.{
    NotificationHandler,
    NotificationDetailHandler,
    ListHandler,
    PermissionHandler
  }
  alias GuiltySpark.NotificationSchema

  @topic_check "check"

  def render(assigns) do
    valid = PermissionHandler.validate_fluffy(assigns.token)
    if valid do
      permissions = permission(assigns)
      GuiltySparkWeb.NotificationView.render("index.html", assigns |> Map.merge(permissions))
    else
      GuiltySparkWeb.ErrorView.render("live_index.html", assigns)
    end
  end

  def mount(params, socket) do
    resp = assign(socket, params |> Map.merge(init_permission()))
      |> init_notification
      GuiltySparkWeb.Endpoint.subscribe(@topic_check)
    {:ok, resp}
  end

  def handle_event("paginator_list", _params, socket) do
    index = socket.assigns.notification_index + 1
    list = Enum.concat(socket.assigns.notifications,
      NotificationHandler.list(index * 10, socket.assigns.search))

    {:noreply, assign(socket,
      show_new: false,
      show_detail: true,
      notifications: list,
      notifications_total: socket.assigns.notifications_total,
      notification_index: index,
      notification_detail: socket.assigns.notification_detail
    )}
  end

  def handle_event("change_detail", params, socket) do

    GuiltySparkWeb.Endpoint.subscribe(@topic_check  )
    {:noreply, assign(socket,
      show_new: false,
      show_detail: true,
      notifications: socket.assigns.notifications,
      notifications_total: socket.assigns.notifications_total,
      notification_index: socket.assigns.notification_index,
      notification_detail: NotificationDetailHandler.detail(%{id: params["id"]}, "")
    )}
  end

  def handle_event("new", _params, socket) do
    {:noreply, assign(socket,
      show_new: true,
      show_detail: false,
      new_conf: %{
        step: 1,
        form: new_form(),
        app_view: app_view(),
        params: params(8)
      },
      notifications: socket.assigns.notifications,
      notifications_total: socket.assigns.notifications_total,
      notification_index: socket.assigns.notification_index,
      notification_detail: socket.assigns.notification_detail
    )}
  end

  def handle_event("new_next", params, socket) do
    {:noreply, assign(socket,
      show_new: true,
      show_detail: false,
      new_conf: %{
        step: NotificationHandler.form_validate(String.to_integer(params["step"]), socket.assigns.new_conf.form),
        form: socket.assigns.new_conf.form,
        app_view: socket.assigns.new_conf.app_view,
        params: socket.assigns.new_conf.params
      }
    )}
  end

  def handle_event("show_detail_list", params, socket) do
    list = ListHandler.list(0)
      |> ListHandler.add_status(socket.assigns.new_conf.form.app_view.list_selected)
    set_app_view(
      params["title"],
      params["description"],
      params["image"],
      String.to_integer(params["type"]),
      list,
      socket.assigns.new_conf.form.app_view.app_view_id,
      socket.assigns.new_conf.form.link_web,
      socket.assigns.new_conf.form.app_view.show_params,
      socket.assigns.new_conf.form.app_view.p1,
      socket.assigns.new_conf.form.app_view.p2,
      socket.assigns.new_conf.form.app_view.list_selected,
      socket)
  end

  def handle_event("app_view", params, socket) do
    app_view_id = String.to_integer(params["app_view_id"])
    set_app_view(
      socket.assigns.new_conf.form.title,
      socket.assigns.new_conf.form.description,
      socket.assigns.new_conf.form.image,
      socket.assigns.new_conf.form.type,
      socket.assigns.new_conf.form.list_list,
      app_view_id,
      params["link_web"],
      show_params(app_view_id),
      socket.assigns.new_conf.form.app_view.p1,
      socket.assigns.new_conf.form.app_view.p2,
      socket.assigns.new_conf.form.app_view.list_selected,
      socket)
  end

  def handle_event("parameters", params, socket) do
    set_app_view(
      socket.assigns.new_conf.form.title,
      socket.assigns.new_conf.form.description,
      socket.assigns.new_conf.form.image,
      socket.assigns.new_conf.form.type,
      socket.assigns.new_conf.form.list_list,
      socket.assigns.new_conf.form.app_view.app_view_id,
      socket.assigns.new_conf.form.link_web,
      socket.assigns.new_conf.form.app_view.show_params,
      params["p1"],
      params["p2"],
      socket.assigns.new_conf.form.app_view.list_selected,
      socket)
  end

  def handle_event("add_list", params, socket) do
    id = String.to_integer(params["id"])
    list = id
      |> ListHandler.get_list_name
      |> ListHandler.concat_list(socket.assigns.new_conf.form.app_view.list_selected)
    list_all = id
      |> ListHandler.change_status(socket.assigns.new_conf.form.list_list)
    set_app_view(
      socket.assigns.new_conf.form.title,
      socket.assigns.new_conf.form.description,
      socket.assigns.new_conf.form.image,
      socket.assigns.new_conf.form.type,
      list_all,
      socket.assigns.new_conf.form.app_view.app_view_id,
      socket.assigns.new_conf.form.link_web,
      socket.assigns.new_conf.form.app_view.show_params,
      socket.assigns.new_conf.form.app_view.p1,
      socket.assigns.new_conf.form.app_view.p2,
      list,
      socket)
  end

  def handle_event("send", _params, socket) do
    case socket.assigns.new_conf.form.type do
      1 -> NotificationHandler.generic_send(socket)
      2 -> NotificationHandler.list_send(socket)
    end
    {:noreply, init_notification(socket)}
  end

  def handle_event("tester", params, socket) do
    IO.inspect(params["value"], label: "PARAMS DEL KEYUP --------->  ")
    list = NotificationHandler.list(0, %{search: params["value"]})
    IO.inspect(list, label: "LIST  LIST  LIST  LIST  LIST  --------->  ")
    {:noreply, assign(socket,
    search: %{search: params["value"]},
    notifications: list
    )}
  end

  def handle_info(%{topic: @topic_check, payload: payload}, socket) do
    {intVal, ""} = Integer.parse(payload.id)
    case intVal == socket.assigns.notification_detail.id do
      true -> {:noreply, assign(socket,
      notification_detail: NotificationDetailHandler.detail(%{id: intVal}, ""))}
      false -> {:noreply, socket}
    end

  end


  def handle_info(_resp, params) do
    init_notification(params)
  end

  def init_notification(socket) do
    list = NotificationHandler.list(0, nil)
    detail = case list == [] do
      true -> NotificationDetailHandler.detail
      false -> NotificationDetailHandler.detail(Enum.at(list, 0))
    end
    assign(socket,
      show_new: false,
      show_detail: true,
      notifications: list,
      notifications_total: NotificationHandler.total(),
      notification_index: 0,
      notification_detail: detail,
      search: nil
    )
  end

  def new_form() do
    %{
      error: [],
      title: nil,
      description: nil,
      image: "",
      type: nil,
      link_web: nil,
      app_view: %{
            app_view_id: 8,
            show_params: false,
            p1: nil,
            p2: nil,
            list_selected: []},
      params: nil
    }
  end

  def set_app_view(title, description, image, type, list, app_view_id, link_web, show_params, p1, p2, list_selected, socket) do
    changeset = NotificationSchema.changeset(%NotificationSchema{}, %{
      image_path: image,
      title: title,
      description: description,
      link: link_web,
      app_view_id: app_view_id,
      json: "{}",
      channel_id: 4,
      type_id: type
    })
    {:noreply, assign(socket,
      show_new: true,
      show_detail: false,
      new_conf: %{
        step: socket.assigns.new_conf.step,
        form: %{
          error: changeset.errors,
          title: title,
          description: description,
          image: image,
          type: type,
          list_list: list,
          link_web: link_web,
          app_view: %{
            app_view_id: app_view_id,
            show_params: show_params,
            p1: p1,
            p2: p2,
            list_selected: list_selected
          }
        },
        app_view: socket.assigns.new_conf.app_view,
        params: params(app_view_id)
      }
    )}
  end

  def app_view() do
    NotificationDetailHandler.app_view()
  end

  def show_params(id) do
    if id == nil do
      false
    else
      NotificationDetailHandler.app_view_show_params(id)
    end
  end

  def params(id) do
    NotificationDetailHandler.app_view_params(id)
  end

  defp init_permission(), do: %{boton_nuevo: false}

  defp permission(assigns) do
    result = PermissionHandler.events_permision(
          assigns.token,
          assigns.role_id,
          assigns.user_id,
          assigns.path)
    case result == %{} do
      true -> %{boton_nuevo: false}
      false -> permission_result(result["data"]["permissions"], %{})
    end
  end

  defp permission_result([head | tail], map) do
    map_aux = map
      |> Map.put_new(head["name"] |> String.replace(" ", "_") |> String.downcase |> String.to_atom, true)
    tail
      |> permission_result(map_aux)
  end

  defp permission_result([], map), do: map

end
