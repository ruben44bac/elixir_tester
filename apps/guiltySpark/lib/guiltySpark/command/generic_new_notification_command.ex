defmodule GuiltySpark.GenericNewNotificationCommand do
  defstruct [
    :title,
    :description,
    :image_path,
    :app_view_id,
    :app_view,
    :parameters,
    :link,
    :json,
    :channel_id,
    :type_id
  ]
  use ExConstructor
end
