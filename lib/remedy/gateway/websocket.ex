defmodule Remedy.Gateway.Websocket do
  @moduledoc """
  Contains all the information required to maintain the gateway websocket connection to Discord.
  """
  use Remedy.Schema, :model

  @primary_key false
  embedded_schema do
    field :shard, :integer
    field :session, :integer
    field :shard_pid, :any, virtual: true

    field :worker, :any, virtual: true
    field :conn_pid, :any, virtual: true
    field :stream, :any, virtual: true
    field :gateway, :string
    field :zlib_context, :any, virtual: true

    # Heartbeat
    field :last_heartbeat_send, :utc_datetime
    field :last_heartbeat_ack, :utc_datetime
    field :heartbeat_ack, :boolean, default: false
    field :heartbeat_interval, :integer
    field :heartbeat_timer, :any, virtual: true

    # Raw ETF. Not guaranteed to be readable
    field :payload, :any, virtual: true

    # Payload items that can actually be used.
    field :opcode, :integer, default: 0
    field :sequence, :integer, default: 0
    field :data, :map, default: %{}
    field :event, :string, default: nil
    field :token, :string, redact: true, default: Application.get_env(:remedy, :token)
  end

  @doc """
  Gets the latency of the shard connection from a `Remedy.Struct.Websocket.t()` struct.

  Returns the latency in milliseconds as an integer, returning nil if unknown.
  """
  def get_shard_latency(%__MODULE__{last_heartbeat_ack: nil}), do: nil

  def get_shard_latency(%__MODULE__{last_heartbeat_send: nil}), do: nil

  def get_shard_latency(
        %__MODULE__{
          last_heartbeat_ack: last_heartbeat_ack,
          last_heartbeat_send: last_heartbeat_send
        } = state
      ) do
    latency = DateTime.diff(last_heartbeat_ack, last_heartbeat_send, :millisecond)

    max(0, latency + if(latency < 0, do: state.heartbeat_interval, else: 0))
  end
end
