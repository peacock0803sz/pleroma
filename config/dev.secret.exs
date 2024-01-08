import Config

config :pleroma, Pleroma.Web.Endpoint,
  http: [
    ip: {0, 0, 0, 0},
    port: 4000
  ],
  debug_errors: true,
  check_origin: false,
  watchers: [],
  secure_cookie_flag: false

config :pleroma, :instance,
  name: "Peacock's Nesting Box",
  email: "peacock0803sz@gmail.com",
  notify_email: "peacock0803sz@gmail.com",
  limit: 5000,
  registrations_open: false,
  federating: true,
  healthcheck: true

config :pleroma, Pleroma.Repo,
  adapter: Ecto.Adapters.Postgres,
  username: "postgres",
  password: "ChangeMe!",
  database: "pleroma",
  hostname: "db",
  port: 5432,
  pool_size: 10,
  timeout: 60_000

config :pleroma, :instance, static_dir: "/var/lib/pleroma/static"

config :pleroma, :shout, enabled: false

config :pleroma, :frontend_configurations,
  pleroma_fe: %{
    showInstanceSpecificPanel: true,
    scopeOptionsEnabled: false,
    webPushNotifications: false
  }

config :logger,
  backends: [:console]

# MetricsExport will not read env when runtime
# So I want to use runtime.exs instead of Mix.Config, but it is not supported, so I'm waiting.
# config :prometheus, Pleroma.Web.Endpoint.MetricsExporter,
#   enabled: true,
#   auth: {:basic, System.fetch_env!("METRICS_USER"), System.fetch_env!("METRICS_PASSWORD")},
#   ip_whitelist: [],
#   path: "/api/pleroma/app_metrics",
#   format: :text
