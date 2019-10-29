defmodule GuiltySparkWeb.ListLiveView do
  use Phoenix.LiveView
  alias GuiltySpark.{
    ListHandler,
    PermissionHandler
  }
  alias GuiltySpark.ListSchema


  def render(assigns) do
    valid = PermissionHandler.validate_fluffy(assigns.token)
    if valid do
      permissions = permission(assigns)
      GuiltySparkWeb.ListView.render("index.html", assigns |> Map.merge(permissions))
    else
      GuiltySparkWeb.ErrorView.render("live_index.html", assigns)
    end
  end
  def mount(params, socket) do
    resp = assign(socket, params |> Map.merge(init_permission()))
      |> init_list
    {:ok, resp}
  end
  def handle_event("change_detail", params, socket) do
    list = ListHandler.get(String.to_integer(params["id"]))
    :timer.cancel(socket.assigns.timer)
    {:noreply, assign(socket,
        show_new: false,
        show_detail: true,
        delete_message: nil,
        counter: 0,
        list: socket.assigns.list,
        detail: %{
          name: list.name,
          id: list.id,
          list: ListHandler.users_for_list(list.id),
          show_add: false
        },
        list_total: socket.assigns.list_total,
        list_index: socket.assigns.list_index
      )
    }
  end

  def handle_event("show_add", params, socket) do
    {:noreply, assign(socket,
        show_new: false,
        show_detail: true,
        list: socket.assigns.list,
        detail: %{
          name: socket.assigns.detail.name,
          id: socket.assigns.detail.id,
          list: socket.assigns.detail.list,
          show_add: params["status"] == "true",
          left_list: ListHandler.left_users_for_list(socket.assigns.detail.id)
        },
        list_total: socket.assigns.list_total,
        list_index: socket.assigns.list_index
      )
    }
  end

  def handle_event("add_user", params, socket) do
    ListHandler.add_user(String.to_integer(params["id"]), socket.assigns.detail.id)
    response_user(socket)
  end

  def handle_event("delete_user", params, socket) do
    ListHandler.delete_user(String.to_integer(params["id"]), String.to_integer(params["userid"]), socket.assigns.detail.id)
    response_user(socket)
  end

  def handle_event("new", _params, socket) do
    {:noreply, assign(socket,
        show_new: true,
        show_detail: false,
        changeset: %ListSchema{}
          |> ListSchema.changeset(%{})
      )
    }
  end

  def handle_event("validate", params, socket) do
    changeset =
      %ListSchema{}
      |> ListSchema.changeset(params)

    {:noreply, assign(socket, changeset: changeset)}
  end

  def handle_event("save", _params, socket) do
    case ListHandler.create_list(socket.assigns.changeset) do
      {:ok, _} -> {:noreply, init_list(socket)}
      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, changeset: changeset)}
    end
  end

  def handle_event("delete_list", _params, socket) do
    if connected?(socket) do
      undo_seconds = Application.get_env(:guiltySpark_web, GuiltySparkWeb.Endpoint)[:undo_seconds]
      test = :timer.send_interval(3500, self(), :tick)
      {:ok, timer} = test
      {:noreply,
       assign(socket,
         delete_message:
           "Si estás seguro de eliminar #{socket.assigns.detail.name} escribe SI",
         counter: undo_seconds,
         timer: timer
       )}
    else
      {:stop, socket}
    end
  end

  def handle_event("validate-delete", params, socket) do
    case params["response_delete"] do
      "SI" -> delete_list(socket)
      _ -> {:noreply, socket}
    end
  end

  def handle_info(:tick, socket) do
    case socket.assigns.counter - 1 do
      0 -> stop_counter(socket)
      restante ->
        {:noreply,
          assign(socket,
            counter: restante,
            delete_message:
              "Si estás seguro de eliminar #{socket.assigns.detail.name} escribe SI"
          )}
    end
  end

  def handle_info(_resp, params) do
    {:noreply, params}
  end

  def init_list(socket) do
    list = ListHandler.list(0)
    assign(socket,
      show_new: false,
      show_detail: true,
      delete_message: nil,
      counter: 0,
      timer: nil,
      list: list,
      detail: %{
        name: Enum.at(list, 0).name,
        id: Enum.at(list, 0).id,
        list: ListHandler.users_for_list(Enum.at(list, 0).id),
        show_add: false
      },
      list_total: ListHandler.total(),
      list_index: 0
    )
  end
  def response_user(socket) do
    {:noreply, assign(socket,
        show_new: false,
        show_detail: true,
        list: ListHandler.update_count_user(socket.assigns.detail.id, socket.assigns.list),
        detail: %{
          name: socket.assigns.detail.name,
          id: socket.assigns.detail.id,
          list: ListHandler.users_for_list(socket.assigns.detail.id),
          show_add: socket.assigns.detail.show_add,
          left_list: ListHandler.left_users_for_list(socket.assigns.detail.id)
        },
        list_total: socket.assigns.list_total,
        list_index: socket.assigns.list_index
      )
    }
  end

  defp stop_counter(socket) do
    :timer.cancel(socket.assigns.timer)
    {:noreply, assign(socket, counter: 0, delete_message: nil)}
  end

  defp delete_list(socket) do
    ListHandler.delete_list(socket.assigns.detail.id)
    :timer.cancel(socket.assigns.timer)
    {:noreply, init_list(socket)}
  end

  defp init_permission(), do: %{
    boton_eliminar: false,
    boton_nuevo: false,
    agregar_usuarios_web: false,
    boton_quitar_usuario_lista: false}

  defp permission(assigns) do
    result = PermissionHandler.events_permision(
          assigns.token,
          assigns.role_id,
          assigns.user_id,
          assigns.path)
    case result == %{} do
      true -> %{boton_eliminar: false,
        boton_nuevo: false,
        agregar_usuarios_web: false,
        boton_quitar_usuario_lista: false}
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
