defmodule Remedy.Shard.Event do
  @moduledoc """
  Handles what to do with events as they arrive from the gateway.

  Arrives as a %Websocket{}.

  ## Return Format

  - `{:reply, reply, socket}` - If an event requires an immediate response.
  - `{:noreply, socket}` - If an event does not require a response.

  No further processing should be done here as the socket needs to be responsive.

  > Send the dispatch events to the producer but I kind of feel like they should be sent by the Shard Session to maintain some sense of context.

  """

  alias Remedy.Shard.Payload
  alias Remedy.Util
  alias Remedy.Gateway.Websocket
  import Remedy.CommandHelpers

  require Logger

  def handle(socket)

  def handle(%Websocket{payload: %{op: op, d: d}} = state) do
  end

  def handle(:heartbeat, _payload, state) do
    Logger.debug("HEARTBEAT PING")
    {state, Payload.heartbeat_payload(state.seq)}
  end

  def handle(:heartbeat_ack, _payload, state) do
    Logger.debug("HEARTBEAT_ACK")
    %{state | last_heartbeat_ack: DateTime.utc_now(), heartbeat_ack: true}
  end

  def handle(:hello, payload, state) do
    state = %{
      state
      | heartbeat_interval: payload.d.heartbeat_interval
    }

    GenServer.cast(state.conn_pid, :heartbeat)

    if session_exists?(state) do
      Logger.info("RESUMING")
      {state, Payload.resume_payload(state)}
    else
      Logger.info("IDENTIFYING")
      {state, Payload.identity_payload(state)}
    end
  end

  def handle(:invalid_session, _payload, state) do
    Logger.info("INVALID_SESSION")
    {state, Payload.identity_payload(state)}
  end

  def handle(:reconnect, _payload, state) do
    Logger.info("RECONNECT")
    state
  end

  def handle(event, _payload, state) do
    Logger.warn("UNHANDLED GATEWAY EVENT #{event}")
    state
  end

  def handle(:dispatch, payload, state) do
    payload = Util.safe_atom_map(payload)

    if Application.get_env(:remedy, :log_dispatch_events),
      do: payload.t |> inspect() |> Logger.debug()

    Producer.notify(Producer, payload, state)

    if payload.t == :READY do
      %{state | session: payload.d.session_id}
    else
      state
    end
  end

  def session_exists?(state) do
    not is_nil(state.session)
  end
end
