use Mix.Config

import_config "../apps/*/config/config.exs"

config :elixir,
  ansi_enabled: true

config :logger,
	level: :debug,
  utc_log: true,
  handle_otp_reports: true,
  handle_sasl_reports: true,
	colors: [enabled: true],
	backends: []