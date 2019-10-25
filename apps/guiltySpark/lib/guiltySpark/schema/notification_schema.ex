defmodule GuiltySpark.NotificationSchema do
  use Ecto.Schema
  import Ecto.Changeset

  @schema_prefix "notification"
  schema "notification" do
    field :title, :string
    field :description, :string
    field :image_path, :string
    field :link, :string
    field :app_view_id, :integer
    field :json, :string

    belongs_to :channel, GuiltySpark.ChannelSchema
    belongs_to :type, GuiltySpark.TypeSchema
    timestamps()
  end

  def changeset(notification, attrs) do
    notification
      |> cast(attrs, [:title, :description, :image_path, :link, :app_view_id, :json, :channel_id, :type_id])
      |> validate_required([:title, :description, :image_path, :link, :app_view_id, :json, :channel_id, :type_id], message: "El dato es requerido")
  end

  def changeset_first(notification, attrs) do
    notification
      |> cast(attrs, [:image_path, :title, :description])
      |> validate_required([:image_path, :title, :description], message: "Debes llenar este tambien")
  end
end
