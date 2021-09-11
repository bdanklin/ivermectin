defmodule Remedy.Gateway.Events.RequestGuildMembers do
  @moduledoc false
  use Remedy.Gateway.Payload

  embedded_schema do
    field :guild_id, :integer
    field :query, :integer
    field :limit, :boolean, default: false
  end

  def send(_socket, opts \\ []) do
    %__MODULE__{
      guild_id: opts.guild_id,
      query: opts.query,
      limit: opts.limit || false
    }
  end
end
