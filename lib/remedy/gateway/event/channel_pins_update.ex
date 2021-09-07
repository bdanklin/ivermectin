defmodule Remedy.Gateway.Event.ChannelPinsUpdate do
  @moduledoc false
  use Remedy.Schema, :model
  @primary_key false

  embedded_schema do
    field :guild_id, Snowflake
    field :channel_id, Snowflake
    field :last_pin_timestamp, ISO8601
  end

  @typedoc "The ID of the guild, if the pin update was on a guild"
  @type guild_id :: Guild.id() | nil

  @typedoc "The ID of the channel"
  @type channel_id :: Channel.id()

  @typedoc "The time at which the most recent pinned message was pinned"
  @type last_pin_timestamp :: DateTime.t() | nil

  @typedoc "Event sent when a message is pinned or unpinned in a text channel"
  @type t :: %__MODULE__{
          guild_id: guild_id,
          channel_id: channel_id,
          last_pin_timestamp: last_pin_timestamp
        }
end
