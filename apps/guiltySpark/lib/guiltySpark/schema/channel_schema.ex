defmodule GuiltySpark.ChannelSchema do
  use Ecto.Schema
  import Ecto.Changeset

  @schema_prefix "notification"
  schema "channel" do
    field :name, :string
    field :status, :boolean

    timestamps()
  end

  def changeset(channel, attrs) do
    channel
      |> cast(attrs, [:name, :status])
  end
end