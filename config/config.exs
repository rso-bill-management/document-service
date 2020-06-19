use Mix.Config


# EXTERNAL APPS CONFIGURATION
config :joken,
  default_signer: {:system, "INVOICING_JOKEN_SECRET"}

config :invoicing_storage,
  data_path: {:system, "INVOICING_STORAGE_DATA_PATH"}

config :logger, level: :info

config :logger, :console,
  format: "$date $time [$level] $metadata⋅$message⋅\n",
  discard_threshold: 2000,
  metadata: [:module, :function, :request_id, :trace_id, :span_id]

config :vex,
  sources: [
    [
      inner_struct: InvoicingSystem.Utils.Validators.InnerStruct,
      tin: InvoicingSystem.Utils.Validators.TaxIdentificationNumner
    ],
    Vex.Validators
  ]

config :phoenix, json_library: Jason


# INVOICING APP CONFIGURATION
config :invoicing_db, InvoicingSystem.DB.Repo,
  database: {:system, "PGDATABASE"},
  username: {:system, "PGUSER"},
  password: {:system, "PGPASSWORD"},
  hostname: {:system, "PGHOST"},
  port: {:system, "PGPORT", {String, :to_integer}}

config :invoicing_api,
       InvoicingSystem.API.Endpoint,
       server: true,
       url: [
         host: "localhost"
       ],
       http: [
         port: "6969"
       ],
       render_errors: [view: InvoicingSystem.API.ErrorView, accepts: ~w(json)]

config :invoicing_db,
  ecto_repos: [InvoicingSystem.DB.Repo]

config :invoicing_invoices,
  templates_path: Path.absname("priv/templates")

import_config "#{Mix.env()}.exs"
