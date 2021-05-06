defmodule Packlane.Repo.Migrations.CreateBankingAccounts do
  use Ecto.Migration

  def change do
    create table(:banking_accounts, primary_key: false) do
      add :id, :binary_id, primary_key: true
      add :name, :string
      add :type, :string
      add :balance, :decimal
      add :user_id, references(:users, on_delete: :nothing)

      timestamps()
    end

    create index(:banking_accounts, [:user_id])
  end
end
