defmodule Remedy.Schema.GuildSystemChannelFlags do
  use Remedy.Flag

  defstruct SUPPRESS_JOIN_NOTIFICATIONS: 1 <<< 0,
            SUPPRESS_PREMIUM_SUBSCRIPTIONS: 1 <<< 1,
            SUPPRESS_GUILD_REMINDER_NOTIFICATIONS: 1 <<< 2,
            SUPPRESS_JOIN_NOTIFICATION_REPLIES: 1 <<< 3
end
