use Mix.Config

config :porcelain,
  driver: Porcelain.Driver.Basic

config :logger, :console,
  format: "\n$time $metadata[$level] $message",
  metadata: [:request_id, :shard, :guild, :channel]

config :remedy,
  token: System.get_env("REMEDY_BOT_TOKEN"),
  gateway_intents: :all,
  num_shards: :auto,
  log_dispatch_events: true
