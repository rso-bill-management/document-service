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
  end

  scope "/", InvoicingSystem.API do
    pipe_through(:api)

    get("/status", StatusController, :status)
    get("/contractors", ContractorController, :index)
  end
end
