defmodule Remedy.Gateway.Dispatch.GuildRoleDelete do
  @moduledoc """
  Dispatched when a new guild channel is created, relevant to the current user.

  ## Payload:

  - %Remedy.Schema.Guild{}.

  """
  use Remedy.Schema
  alias Remedy.Cache
  alias Remedy.Schema.Role

  embedded_schema do
    field :guild_id, Snowflake
    embeds_one :role, Role
  end

  def handle({event, %{role: role} = payload, socket}) do
    role
    |> Cache.delete_role()

    {event,
     payload
     |> new(), socket}
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
    cast(model, params, __MODULE__.__schema__(:fields) -- __MODULE__.__schema__(:embeds))
    |> cast_embeds()
  end

  defp cast_embeds(cast_model) do
    Enum.reduce(__MODULE__.__schema__(:embeds), cast_model, &cast_embed(&1, &2))
  end

  defp castable do
    __MODULE__.__schema__(:fields) -- __MODULE__.__schema__(:embeds)
  end
end
