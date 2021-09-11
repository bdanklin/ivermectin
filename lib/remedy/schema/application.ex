defmodule Remedy.Schema.App do
  @moduledoc false
  use Remedy.Schema

  @primary_key {:id, Snowflake, autogenerate: false}
  schema "applications" do
    field :name, :string
    field :icon, :string
    field :description, :string
    field :rpc_origins, {:array, :string}
    field :bot_public, :boolean
    field :bot_require_code_grant, :boolean
    field :terms_of_service_url, :string
    field :privacy_policy_url, :string
    field :cover_image, :string
    field :flags, :integer
    field :summary, :string
    field :verify_key, :string

    belongs_to :owner, User
    belongs_to :team, Team
    belongs_to :guild_id, Guild
    field :primary_sku_id, Snowflake
    field :slug, :string
  end
end

defmodule Remedy.Schema.Team do
  @moduledoc false
  use Remedy.Schema
  alias Remedy.Schema.TeamMember

  @primary_key {:id, :id, autogenerate: false}
  schema "teams" do
    field :icon, :string
    field :name, :string
    field :owner_user_id, Snowflake
    has_one :application, App
    has_many :members, TeamMember
  end
end

defmodule Remedy.Schema.TeamMember do
  @moduledoc false
  use Remedy.Schema

  @primary_key false
  schema "team_members" do
    field :membership_state, :integer
    field :permissions, {:array, :string}
    belongs_to :team, Team
    belongs_to :user, User
  end
end
