defmodule Packlane.Repo.Migrations.CreateBankingTransactions do
  use Ecto.Migration

  def change do
    create table(:banking_transactions, primary_key: false) do
      add :id, :binary_id, primary_key: true
      add :type, :string
      add :amount, :decimal
      add :to_id, references(:banking_accounts, on_delete: :nothing, type: :binary_id)
      add :from_id, references(:banking_accounts, on_delete: :nothing, type: :binary_id)

      timestamps()
    end

    create index(:banking_transactions, [:to_id])
    create index(:banking_transactions, [:from_id])
  end
end
