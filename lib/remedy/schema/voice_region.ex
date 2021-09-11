defmodule Remedy.Schema.VoiceRegion do
  @moduledoc false
  use Remedy.Schema
  @primary_key {:id, :string, autogenerate: false}

  schema "voice_regions" do
    field :name, :string
    field :vip, :boolean
    field :optimal, :boolean
    field :deprecated, :boolean
    field :custom, :boolean
  end
end
