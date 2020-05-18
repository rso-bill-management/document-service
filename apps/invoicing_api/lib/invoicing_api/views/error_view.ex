defmodule Invoicing.API.ErrorView do
  def render(error, _) do
    %{error: Phoenix.Controller.status_message_from_template(error)}
  end
end
