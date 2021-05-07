defmodule Packlane.Repo.Migrations.AddBalanceConstraintToBankingAccounts do
  use Ecto.Migration

  def change do
    create constraint("banking_accounts", :balance_must_be_not_be_negative, check: "balance >= 0")
  end
end
