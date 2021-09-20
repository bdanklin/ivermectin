defmodule Remedy.Gateway.Dispatch.PresenceUpdate do
  @moduledoc false
  use Remedy.Schema
  @primary_key {:id, Snowflake, autogenerate: false}

  # either "idle", "dnd", "online", or "offline"

  embedded_schema do
    belongs_to :user, User
    belongs_to :guild, Guild
    field :status, :string
    embeds_one :client_status, ClientStatus
    embeds_many :activities, Activity
  end

  def handle({event, payload, socket}) do
    {event, new(payload), socket}
  end

  def new(params) do
    params
    |> changeset()
    |> validate()
    |> apply_changes()
  end

  def update(model, params) do
    model
    |> changeset(params)
    |> validate()
    |> apply_changes()
  end

  def validate(changeset), do: changeset

  def changeset(params), do: changeset(%__MODULE__{}, params)
  def changeset(nil, params), do: changeset(%__MODULE__{}, params)

  def changeset(%__MODULE__{} = model, params) do
    cast(model, params, castable())
    |> cast_embeds()
  end

  defp cast_embeds(cast_model) do
    Enum.reduce(__MODULE__.__schema__(:embeds), cast_model, &cast_embed(&1, &2))
  end

  defp castable do
    __MODULE__.__schema__(:fields) -- __MODULE__.__schema__(:embeds)
  end
end
