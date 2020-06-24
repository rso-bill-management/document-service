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

    get("/predefined_items", InvoiceController, :predefined_items)
    post("/predefined_items", InvoiceController, :new_predefined_item)

    get("/invoice/:uuid/pdf", InvoiceController, :pdf)
    get("/invoices", InvoiceController, :index)
  end

  scope "/", InvoicingSystem.API do
    pipe_through(:api)
    get("/status", StatusController, :status)
  end
end
