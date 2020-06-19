defmodule InvoicingApi.Repo.Migrations.CreateCreateContractors do
  use Ecto.Migration

  def change do
    create table(:create_contractors) do
      add :id, :string
      add :name, :string
      add :taxpayerIdentificationNumber, :string
      add :town, :string
      add :street, :string
      add :postalCode, :string

      timestamps()
    end

  end
end
