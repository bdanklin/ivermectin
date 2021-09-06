defmodule Remedy.Gateway.Commands.RequestGuildMembers do
  @moduledoc false
  use Remedy.Schema, :payload

  embedded_schema do
    field :guild_id, Snowflake
    field :query, :string
    field :limit
    field :presences
    field :user_ids
  end

  @defaults %{
    guild_id: 872_417_560_094_732_328,
    limit: 1,
    user_ids: 883_307_747_305_725_972
  }

  def payload(state, opts \\ [])

  def payload(%WSState{}, opts) do
    opts
    |> Enum.into(@defaults)
    |> build_payload()
  end
end
