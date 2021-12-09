defmodule Remedy.Schema.App do
  @moduledoc """
  Discord Application Object
  """
  use Remedy.Schema

  @type t :: %__MODULE__{
          id: Snowflake.t(),
          name: String.t(),
          icon: String.t(),
          description: String.t(),
          #      rpc_origins: [String.t()],
          bot_public: boolean(),
          bot_require_code_grant: boolean(),
          terms_of_service_url: String.t(),
          privacy_policy_url: String.t(),
          owner: ApplicationOwner.t(),
          cover_image: String.t(),
          flags: integer()
          #     hook: boolean()
        }

  @primary_key {:id, Snowflake, autogenerate: false}
  schema "applications" do
    field :name, :string
    field :icon, :string
    field :description, :string
    field :bot_public, :boolean
    field :bot_require_code_grant, :boolean
    field :terms_of_service_url, :string
    field :privacy_policy_url, :string
    field :cover_image, :string
    field :flags, :integer

    embeds_one :owner, ApplicationOwner
    field :remedy_system, :boolean, default: false, redact: true
  end

  @doc false
  def changeset(model \\ %__MODULE__{}, params) do
    model
    |> cast(params, __MODULE__.__schema__(:fields) -- __MODULE__.__schema__(:embeds))
    |> cast_embed(:owner)
  end

  def system_changeset(model \\ %__MODULE__{}, params) do
    model
    |> changeset(params)
    |> put_change(:remedy_system, true)
  end
end

defmodule Remedy.Schema.ApplicationOwner do
  use Remedy.Schema

  @primary_key {:id, Snowflake, autogenerate: false}
  embedded_schema do
    field :avatar, :string
    field :discriminator, :integer
    field :username, :string
  end

  def changeset(model \\ %__MODULE__{}, params) do
    model
    |> cast(params, [:id, :discriminator, :avatar, :username])
  end
end
