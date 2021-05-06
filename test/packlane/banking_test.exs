defmodule Packlane.BankingTest do
  use Packlane.DataCase

  alias Packlane.Banking

  describe "banking_accounts" do
    alias Packlane.Banking.Account

    @valid_attrs %{balance: "120.5", name: "some name", type: "checking"}
    @update_attrs %{balance: "456.7", name: "some updated name", type: "savings"}
    @invalid_attrs %{balance: nil, name: nil, type: nil}

    def account_fixture(attrs \\ %{}) do
      {:ok, account} =
        attrs
        |> Enum.into(@valid_attrs)
        |> Banking.create_account()

      account
    end

    setup do
      user = Packlane.AccountsFixtures.user_fixture()

      %{user: user}
    end

    test "list_banking_accounts/0 returns all banking_accounts", %{user: user} do
      account = account_fixture(%{user_id: user.id})
      assert Banking.list_banking_accounts() == [account]
    end

    test "get_account!/1 returns the account with given id", %{user: user} do
      account = account_fixture(%{user_id: user.id})
      assert Banking.get_account!(account.id) == account
    end

    test "create_account/1 with valid data creates a account", %{user: user} do
      assert {:ok, %Account{} = account} = Banking.create_account(Map.put(@valid_attrs, :user_id, user.id))
      assert account.balance == Decimal.new("120.5")
      assert account.name == "some name"
      assert account.type == :checking
    end

    test "create_account/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Banking.create_account(@invalid_attrs)
    end

    test "update_account/2 with valid data updates the account", %{user: user} do
      account = account_fixture(%{user_id: user.id})
      assert {:ok, %Account{} = account} = Banking.update_account(account, @update_attrs)
      assert account.balance == Decimal.new("456.7")
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
end
