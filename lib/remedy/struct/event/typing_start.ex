defmodule Remedy.Struct.Event.TypingStart do
  @moduledoc "Sent when a user starts typing in a channel"
  @moduledoc since: "0.5.0"

  alias Remedy.Struct.Channel
  alias Remedy.Struct.Guild
  alias Remedy.Struct.Guild.Member
  alias Remedy.Struct.User
  alias Remedy.Util

  defstruct [:channel_id, :guild_id, :user_id, :timestamp, :member]

  @typedoc "Channel in which the user started typing"
  @type channel_id :: Channel.id()

  @typedoc "ID of the guild where the user started typing, if applicable"
  @type guild_id :: Guild.id() | nil

  @typedoc "ID of the user who started typing"
  @type user_id :: User.id()

  @typedoc "Unix time (in seconds) of when the user started typing"
  @type timestamp :: pos_integer()

  @typedoc "The member who started typing if this happened in a guild"
  @type member :: Member.t() | nil

  @typedoc "Event sent when a user starts typing in a channel"
  @type t :: %__MODULE__{
          channel_id: channel_id,
          guild_id: guild_id,
          user_id: user_id,
          timestamp: timestamp,
          member: member
        }

  @doc false
  def to_struct(map) do
    %__MODULE__{
      channel_id: map.channel_id,
      guild_id: map[:guild_id],
      user_id: map.user_id,
      timestamp: map.timestamp,
      member: Util.cast(map[:member], {:struct, Member})
    }
  end
end
