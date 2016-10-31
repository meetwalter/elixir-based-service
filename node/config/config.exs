use Mix.Config

import_config "../apps/*/config/config.exs"

config :elixir,
  ansi_enabled: true

config :exuvia,
  host_key: {:dir, "/run/exuvia/host-keys"},
  auth: Exuvia.KeyBag.Github

config :logger,
	level: :info,
  utc_log: true,
  handle_otp_reports: true,
  handle_sasl_reports: true,
	colors: [enabled: true],
	backends: []
