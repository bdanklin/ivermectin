defmodule Remedy.Gateway.Events.Resume do
  @moduledoc false
  use Remedy.Gateway.Payload
  @dialyzer {:no_missing_calls}
  embedded_schema do
    field :token_id, :string
    field :session_id, :string
    field :sequence, :integer
  end

  def payload(
        %WSState{session_id: session_id, payload_sequence: payload_sequence} = socket,
        _opts
      ) do
    {%__MODULE__{
       token_id: Application.get_env(:remedy, :token),
       session_id: session_id,
       sequence: payload_sequence
     }, socket}
  end
end
