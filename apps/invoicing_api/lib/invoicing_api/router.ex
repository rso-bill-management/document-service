defmodule InvoicingSystem.API.Router do
  use InvoicingSystem.API, :router

  alias InvoicingSystem.API.Plugs

  @crud_actions [:index, :create, :update, :show, :delete]

  pipeline :unrestricted_api do
    plug(:accepts, ["json"])
  end

  pipeline :api do
    plug(:accepts, ["json"])
    plug(Plugs.Authenticate)
    plug(Plugs.RefreshToken)
  end

  scope "/", InvoicingSystem.API do
    pipe_through(:unrestricted_api)

    post("/login", LoginController, :login)
    post("/register", RegisterController, :register)
  end

  scope "/invoicing", InvoicingSystem.API do
    pipe_through(:api)

    get("/contractors", InvoiceController, :contractors)
    post("/contractors", InvoiceController, :new_contractor)

    get("/invoice/:uuid/pdf", InvoiceController, :pdf)
  end

  scope "/", InvoicingSystem.API do
    pipe_through(:api)
    get("/status", StatusController, :status)
  end
end
