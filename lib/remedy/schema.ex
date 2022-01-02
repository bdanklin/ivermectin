defmodule Remedy.Schema do
  @moduledoc """
  Schema sets out all of the objects and types used within the Discord API.

  """
  def schema_alias do
    quote do
      alias Remedy.Schema.{
        Activity,
        App,
        ApplicationFlags,
        ApplicationOwner,
        Attachment,
        AuditLog,
        AuditLogEntry,
        AuditLogActionType,
        AuditLogOption,
        AuditLogOptionType,
        Ban,
        Callback,
        CallbackData,
        CallbackDataFlags,
        CallbackType,
        Channel,
        ChannelType,
        ChannelPinsUpdate,
        ClientStatus,
        Command,
        CommandOption,
        CommandOptionChoice,
        CommandPermission,
        CommandPermissionType,
        CommandType,
        Component,
        ComponentType,
        ComponentOption,
        Embed,
        EmbedAuthor,
        EmbedField,
        EmbedFooter,
        EmbedImage,
        EmbedProvider,
        EmbedThumbnail,
        EmbedVideo,
        Emoji,
        Event,
        EventStatus,
        EventPrivacyLevel,
        EventEntityMetadata,
        EventEntityType,
        Guild,
        GuildBanAdd,
        GuildBanRemove,
        GuildEmojisUpdate,
        GuildMemberRemove,
        GuildMembersChunk,
        GuildMemberUpdate,
        GuildRoleCreate,
        GuildRoleUpdate,
        GuildSystemChannelFlags,
        Integration,
        IntegrationExpireType,
        IntegrationType,
        Interaction,
        InteractionData,
        InteractionDataOption,
        InteractionDataResolved,
        InteractionType,
        Member,
        Message,
        MessageActivity,
        MessageActivityType,
        MessageFlags,
        MessageReaction,
        MessageReactionRemoveEmoji,
        MessageReference,
        MessageType,
        PermissionOverwrite,
        PermissionOverwriteType,
        Presence,
        PresenceUpdate,
        Provider,
        Reaction,
        Role,
        Stage,
        StagePrivacyLevel,
        Sticker,
        StickerFormatType,
        StickerPack,
        StickerType,
        Team,
        TeamMember,
        Thread,
        ThreadMember,
        ThreadMemberFlags,
        ThreadMetadata,
        UnavailableGuild,
        User,
        UserFlags,
        Voice,
        VoiceState,
        Webhook,
        WebhookType,
        WelcomeScreen,
        WelcomeScreenChannel
      }

      alias Remedy.{
        ISO8601,
        Snowflake,
        Colour
      }
    end
  end

  defmacro __using__(which) when which in [:schema_alias] do
    apply(__MODULE__, which, [])
  end

  defmacro __using__(_options) do
    parent = __MODULE__

    quote do
      alias unquote(parent)

      use Ecto.Schema
      import Ecto.Changeset
      unquote(schema_alias())
    end
  end
end
