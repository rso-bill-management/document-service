defmodule InvoicingApi.Repo.Migrations.CreateCreateContractors do
  use Ecto.Migration

  def change do
    create table(:create_contractors, primary_key: false) do
      add :id, :string, primary_key: true
      add :name, :string
      add :taxpayerIdentificationNumber, :string
      add :town, :string
      add :street, :string
      add :postalCode, :string

      timestamps()
    end

  end
end
