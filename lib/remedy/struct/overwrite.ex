defmodule Remedy.Struct.Overwrite do
  @moduledoc """
  Struct representing a Discord overwrite.
  """

  alias Remedy.{Snowflake, Util}

  defstruct [
    :id,
    :type,
    :allow,
    :deny
  ]

  @typedoc "Role or User id"
  @type id :: Snowflake.t()

  @typedoc "Either 'role' or 'member'"
  @type type :: String.t()

  @typedoc "Permission bit set"
  @type allow :: integer

  @typedoc "Permission bit set"
  @type deny :: integer

  @type t :: %__MODULE__{
          id: id,
          type: type,
          allow: allow,
          deny: deny
        }

  @doc false
  def p_encode do
    %__MODULE__{}
  end

  @doc false
  def to_struct(map) do
    new =
      map
      |> Map.new(fn {k, v} -> {Util.maybe_to_atom(k), v} end)
      |> Map.update(:id, nil, &Util.cast(&1, Snowflake))

    struct(__MODULE__, new)
  end
end
