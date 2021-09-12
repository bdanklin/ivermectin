defmodule Remedy.Gateway.Payload do
  @moduledoc """
  Payload represents the data packet set to discord through the API. All processing of the payload should be done within this context as it will be cleared upon returning to the session process.

  > These functions exist to attempt friendly discourse with the ill mannered Discord gateway. Documentation is included for completeness but using them is at your peril!

  ## Fields

  - `op:` Opcode.
  - `d:`  Data.
  - `s:`  Sequence.
  - `t:`  Event Name.

  ## Sending

  ### `send/2`

  Any event that will be delivered to discord must contain a `send/2` function. It is given the socket and a keyword list of options, and returns just the payload data. This will be dispatched upon receiving an event of the module name converted to **discord** case.

  For example: if the session receives a message of `:HEARTBEAT`. The socket will immediately be passed to `Payload.Heartbeat.send/2`. Therefore the `%Websocket{}` struct must contain all of the required information to return the heartbeat. **Once the payload has been sent, the payload field will be cleared.**

  The only requirement of `payload/2` is that it returns the payload data. the other fields will automatically be calculated. The `HeartbeatAck` module simply returns the

  ## Receiving

  ### `intake/2`

  Some payloads coming from discord should be immediately decoded and their information added to the socket. For each of these data types an `intake/2` function should be included

  Mappings to use these functions are provided from within the `Remedy.Gateway` module.

  ## Dispatching

  Events that are dispatched to our consumer will generally require more expenisve processing, such as caching etc. This

  Modules that `use Payload` will have their data packed and passed to this function through the `send` callback.

  The callback described above is only required to return the raw data. It is further
  """

  defmacro __using__(_) do
    parent = __MODULE__

    quote do
      alias unquote(parent)
      import Remedy.OpcodeHelpers
      use Ecto.Schema
      alias Remedy.Gateway.{Payload, Websocket}

      alias Remedy.Gateway.Events.{
        Heartbeat,
        Hello,
        Identify,
        RequestGuildMembers,
        Resume,
        UpdatePresence,
        UpdateVoiceState
      }

      ## Requests from Payload.send are delivered through `send_payload/2`

      @doc false
      def build_payload(socket, opts) do
        Payload.send_out(event_from_mod(), payload(socket, opts))
      end

      @doc """
      This function should be overridden per this format to enable sending of this event.

      ```elixir
      def payload(socket, opts), do: {payload, socket}
      ```

      """
      def payload(socket, opts \\ []), do: {:noop, socket}

      def do_digest(socket, payload) do
        Payload.digest_in(event_from_mod(), digest(socket, payload))
      end

      @doc """
      This function should be overridden to enable sending of this event.
      """
      def digest(socket, _payload), do: {:noop, socket}

      defoverridable(payload: 2, digest: 2)
    end
  end

  @type payload :: map()
  @type socket :: Websocket.t()
  @type opts :: list() | nil

  @doc """
  Describes how to take the current socket state and construct the payload data for this modules event type.

  For example: `Heartbeat.send/2` will take the socket, and a keyword list of options, and construct the payload data for the event of type `:HEARTBEAT`. It is the responsibility of the developer to ensure that all events required to be sent implement this function.

  If the behaviour is not described. Passing this function will just pass the socket back to session to continue doing what it do.
  """
  @callback payload(socket, opts) :: any()

  @doc """
  Digest the data frame from Discord and loads the data into the socket. For example:

  - The `:heartbeat_ack` flag on the websocket needs to be set to true once the `:HEARTBEAT_ACK` event is received from discord.

  In short. Do what you need to do with the payload. because its going away
  """
  @callback digest(socket, payload) :: socket

  @optional_callbacks payload: 2, digest: 2

  alias Remedy.Gateway.Websocket
  import Remedy.{ModelHelpers, OpcodeHelpers}
  require Logger

  @doc """
  Used internally to take the output from an events `payload/2` functions.

  The arguments consist of the Discord command, eg `:READY`, auto generated by: `event_from_mod/0`. And a two part tuple of the form `{:noop, %Websocket{}}` or `{payload_data, %Websocket{}}`. The default implementation is inserted automatically through use.
  """
  def send(socket, event, opts \\ []) when is_op_event(event) do
    Module.concat([event]).build_payload(socket, opts)
  end

  def send_out(_command, {:noop, socket}) do
    socket
  end

  def send_out(command, {payload, socket}) do
    %{
      "d" => crush(payload),
      "op" => op_code(command)
    }
    |> flatten()
    |> :erlang.term_to_binary()
    |> Gun.send(socket)
  end

  # add generic payload data
  # delegate to specific
  def digest(socket, frame) do
    {payload, socket} = Gun.unpack_frame(socket, frame)

    event = op_event(payload["op"])

    socket = %Websocket{
      socket
      | payload_op_code: payload.op,
        payload_op_event: event,
        payload_sequence: payload["seq"],
        payload_data: payload["d"],
        payload_dispatch_event: payload["t"]
    }

    Module.concat([event]).digest(socket, payload["d"])
  end

  def digest_in(command, socket) do
    Logger.debug("#{command}")
    socket
  end

  defp crush(map), do: map |> flatten() |> Morphix.stringmorphiform!()
  defp flatten(map), do: :maps.map(&dfl/2, map)
  defp dfl(_key, value), do: enm(value)
  defp enm(list) when is_list(list), do: Enum.map(list, &enm/1)
  defp enm(%{__struct__: _} = strct), do: :maps.map(&dfl/2, Map.from_struct(strct))
  defp enm(data), do: data
end
