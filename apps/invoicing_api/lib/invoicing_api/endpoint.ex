defmodule Invoicing.API.Endpoint do
  use Phoenix.Endpoint, otp_app: :surveyor_rpc

  plug(Plug.Parsers,
    pass: ["application/json"],
    parsers: [:json],
    json_decoder: Phoenix.json_library()
  )

  plug(Plug.Static, at: "/", from: Path.absname("../../priv/static"))

  plug(Invoicing.API.Router)
end
