defmodule Remedy.Dispatch do
  @moduledoc false
  alias Remedy.Dispatch.{Buffer, BufferOut, Pipeline}

  use Supervisor

  def start_link(_args) do
    Supervisor.start_link(__MODULE__, [], name: __MODULE__)
  end

  def init(_args) do
    children = [
      {Buffer, []},
      {Pipeline, []},
      {BufferOut, []}
    ]

    Supervisor.init(children, strategy: :one_for_one, max_restarts: 1000, max_seconds: 60)
  end
end
