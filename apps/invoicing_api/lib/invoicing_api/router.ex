defmodule Invoicing.API.Router do
  use Invoicing.API, :router

  alias Invoicing.API.Plugs

  @crud_actions [:index, :create, :update, :show, :delete]

  pipeline :unrestricted_api do
    plug(:accepts, ["json"])
  end
end
