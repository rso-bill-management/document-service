defmodule InvoicingApi.InvoincingApi.Contractor do
  use Ecto.Schema
  import Ecto.Changeset

  schema "create_contractors" do
    field :id, :string
    field :name, :string
    field :postalCode, :string
    field :street, :string
    field :taxpayerIdentificationNumber, :string
    field :town, :string

    timestamps()
  end

  @doc false
  def changeset(contractor, attrs) do
    contractor
    |> cast(attrs, [:id, :name, :taxpayerIdentificationNumber, :town, :street, :postalCode])
    |> validate_required([:id, :name, :taxpayerIdentificationNumber, :town, :street, :postalCode])
  end
end
