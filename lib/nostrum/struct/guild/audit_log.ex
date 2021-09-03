defmodule Remedy.Struct.Guild.AuditLog do
  @moduledoc """
  Represents a guild's audit log.
  """

  alias Remedy.Struct.Guild.AuditLogEntry
  alias Remedy.Struct.{User, Webhook}
  alias Remedy.Util

  defstruct [:entries, :users, :webhooks]

  @typedoc "Entries of this guild's audit log"
  @type entries :: [AuditLogEntry.t()]

  @typedoc "Users found in the audit log"
  @type users :: [User.t()]

  @typedoc "Webhooks found in the audit log"
  @type webhooks :: [Webhook.t()]

  @type t :: %__MODULE__{
          entries: entries,
          users: users,
          webhooks: webhooks
        }

  @doc false
  def to_struct(map) do
    new =
      map
      |> Map.new(fn {k, v} -> {Util.maybe_to_atom(k), v} end)
      |> Map.update(:audit_log_entries, nil, &Util.cast(&1, {:list, {:struct, AuditLogEntry}}))
      |> Map.update(:users, nil, &Util.cast(&1, {:list, {:struct, User}}))
      |> Map.update(:webhooks, nil, &Util.cast(&1, {:list, {:struct, Webhook}}))

    struct(__MODULE__, new)
  end
end
