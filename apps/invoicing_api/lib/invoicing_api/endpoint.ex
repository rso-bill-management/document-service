defmodule InvoicingSystem.API.Endpoint do
  use Phoenix.Endpoint, otp_app: :invoicing_api

  plug(Plug.Parsers,
    pass: ["application/json"],
    parsers: [:json],
    json_decoder: Phoenix.json_library()
  )

  plug(Plug.Static, at: "/", from: Path.absname("../../priv/static"))

  plug(InvoicingSystem.API.Router)
end
