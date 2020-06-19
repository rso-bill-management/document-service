defmodule InvoicingSystem.DB.Repo.Migrations.CreateUsers do
  use Ecto.Migration

  def change do
    create table(:users, primary_key: false) do
      add(:uuid, :uuid, primary_key: true)
      add(:data, :binary, null: false)
    end

    create table(:users_data, primary_key: false) do
      add(:uuid, :uuid, primary_key: true)
      add(:data, :binary, null: false)
    end
  end
end

