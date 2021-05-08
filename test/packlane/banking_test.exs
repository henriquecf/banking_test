defmodule Packlane.BankingTest do
  use Packlane.DataCase
  import Packlane.BankingFixtures

  alias Packlane.Banking

  setup do
    user = Packlane.AccountsFixtures.user_fixture()

    %{user: user}
  end

  describe "banking_accounts" do
    alias Packlane.Banking.Account

    @valid_attrs %{balance: "120.5", name: "some name", type: "checking"}
    @update_attrs %{balance: "456.7", name: "some updated name", type: "savings"}
    @invalid_attrs %{balance: nil, name: nil, type: nil}

    test "list_banking_accounts/0 returns all banking_accounts", %{user: user} do
      account = account_fixture(%{user_id: user.id})
      assert Banking.list_banking_accounts(user.id) == [account]
    end

    test "get_account!/1 returns the account with given id", %{user: user} do
      account = account_fixture(%{user_id: user.id})
      assert Banking.get_account!(account.id) == account
    end

    test "create_account/1 with valid data creates a account", %{user: user} do
      assert {:ok, %Account{} = account} = Banking.create_account(Map.put(@valid_attrs, :user_id, user.id))
      assert account.balance == Decimal.new("0")
      assert account.name == "some name"
      assert account.type == :checking
    end

    test "create_account/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Banking.create_account(@invalid_attrs)
    end

    test "update_account/2 with valid data updates the account", %{user: user} do
      account = account_fixture(%{user_id: user.id})
      assert {:ok, %Account{} = account} = Banking.update_account(account, @update_attrs)
      assert account.balance == Decimal.new("0")
      assert account.name == "some updated name"
      assert account.type == :savings
    end

    test "update_account/2 with invalid data returns error changeset", %{user: user} do
      account = account_fixture(%{user_id: user.id})
      assert {:error, %Ecto.Changeset{}} = Banking.update_account(account, @invalid_attrs)
      assert account == Banking.get_account!(account.id)
    end

    test "delete_account/1 deletes the account", %{user: user} do
      account = account_fixture(%{user_id: user.id})
      assert {:ok, %Account{}} = Banking.delete_account(account)
      assert_raise Ecto.NoResultsError, fn -> Banking.get_account!(account.id) end
    end

    test "change_account/1 returns a account changeset", %{user: user} do
      account = account_fixture(%{user_id: user.id})
      assert %Ecto.Changeset{} = Banking.change_account(account)
    end
  end

  describe "banking_transactions" do
    alias Packlane.Banking.Transaction

    @valid_attrs %{amount: "200", type: "deposit"}
    @invalid_attrs %{amount: nil, type: nil}

    test "list_banking_transactions/0 returns all banking_transactions", %{user: user} do
      account = account_fixture(%{user_id: user.id})
      transaction = transaction_fixture(%{to_id: account.id})
      assert Banking.list_banking_transactions(user.id) == [transaction]
    end

    test "get_transaction!/1 returns the transaction with given id", %{user: user} do
      account = account_fixture(%{user_id: user.id})
      transaction = transaction_fixture(%{to_id: account.id})
      assert Banking.get_transaction!(transaction.id) == transaction
    end

    test "create_transaction/1 with valid data creates a transaction and updates account balance", %{user: user} do
      account = account_fixture(%{user_id: user.id})
      valid_attrs = Map.put(@valid_attrs, :to_id, account.id)
      assert {:ok, %Transaction{} = transaction} = Banking.create_transaction(valid_attrs)
      assert transaction.amount == Decimal.new("200")
      assert transaction.type == :deposit
      assert Repo.preload(transaction, :to) |> Map.get(:to) |> Map.get(:balance) == Decimal.new("200")
    end

    test "create_transaction/1 with invalid data returns error changeset", %{user: user} do
      account = account_fixture(%{user_id: user.id})
      invalid_attrs = Map.put(@invalid_attrs, :to, account.id)
      assert {:error, %Ecto.Changeset{}} = Banking.create_transaction(invalid_attrs)
    end

    test "create_transaction/1 fails if account has no balance", %{user: user} do
      account = account_fixture(%{user_id: user.id})
      valid_attrs = Map.put(@valid_attrs, :from_id, account.id) |> Map.put(:type, :withdraw)
      assert {:error, "withdraw failed due to insuficient balance"} = Banking.create_transaction(valid_attrs)
      assert Banking.get_account!(account.id) |> Map.get(:balance) == Decimal.new("0")
    end
  end
end
