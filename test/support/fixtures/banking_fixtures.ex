defmodule Packlane.BankingFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `Packlane.Banking` context.
  """

  alias Packlane.Banking

  @valid_account_attrs %{balance: "120.5", name: "some name", type: "checking"}
  @valid_transaction_attrs %{amount: "120.5", type: "deposit"}

  def account_fixture(attrs \\ %{}) do
    {:ok, account} =
      attrs
      |> Enum.into(@valid_account_attrs)
      |> Banking.create_account()

    account
  end

  def transaction_fixture(attrs \\ %{}) do
    {:ok, transaction} =
      attrs
      |> Enum.into(@valid_transaction_attrs)
      |> Banking.create_transaction()

    transaction
  end
end
