defmodule Packlane.Banking do
  @moduledoc """
  The Banking context.
  """

  import Ecto.Query, warn: false
  alias Packlane.Repo
  alias Ecto.Multi

  alias Packlane.Banking.Account

  @doc """
  Returns the list of banking_accounts.

  ## Examples

      iex> list_banking_accounts()
      [%Account{}, ...]

  """
  def list_banking_accounts(user_id) do
    query = from a in Account,
      where: a.user_id == ^user_id,
      order_by: [asc: :name]
    Repo.all(query)
  end

  @doc """
  Gets a single account.

  Raises `Ecto.NoResultsError` if the Account does not exist.

  ## Examples

      iex> get_account!(123)
      %Account{}

      iex> get_account!(456)
      ** (Ecto.NoResultsError)

  """
  def get_account!(id), do: Repo.get!(Account, id)

  @doc """
  Creates a account.

  ## Examples

      iex> create_account(%{field: value})
      {:ok, %Account{}}

      iex> create_account(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_account(attrs \\ %{}) do
    %Account{}
    |> Account.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a account.

  ## Examples

      iex> update_account(account, %{field: new_value})
      {:ok, %Account{}}

      iex> update_account(account, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_account(%Account{} = account, attrs) do
    account
    |> Account.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a account.

  ## Examples

      iex> delete_account(account)
      {:ok, %Account{}}

      iex> delete_account(account)
      {:error, %Ecto.Changeset{}}

  """
  def delete_account(%Account{} = account) do
    Repo.delete(account)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking account changes.

  ## Examples

      iex> change_account(account)
      %Ecto.Changeset{data: %Account{}}

  """
  def change_account(%Account{} = account, attrs \\ %{}) do
    Account.changeset(account, attrs)
  end

  alias Packlane.Banking.Transaction

  @doc """
  Returns the list of banking_transactions.

  ## Examples

      iex> list_banking_transactions()
      [%Transaction{}, ...]

  """
  def list_banking_transactions(user_id) do
    query = from t in Transaction,
      left_join: to in assoc(t, :to),
      left_join: from in assoc(t, :from),
      where: to.user_id == ^user_id or from.user_id == ^user_id
    Repo.all(query)
  end

  @doc """
  Gets a single transaction.

  Raises `Ecto.NoResultsError` if the Transaction does not exist.

  ## Examples

      iex> get_transaction!(123)
      %Transaction{}

      iex> get_transaction!(456)
      ** (Ecto.NoResultsError)

  """
  def get_transaction!(user_id, id) do
    query = from t in Transaction,
      left_join: to in assoc(t, :to),
      left_join: from in assoc(t, :from),
      where: to.user_id == ^user_id or from.user_id == ^user_id
    Repo.get!(query, id)
  end

  @doc """
  Creates a transaction.

  ## Examples

      iex> create_transaction(%{field: value})
      {:ok, %Transaction{}}

      iex> create_transaction(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_transaction(attrs \\ %{}) do
    Multi.new()
    |> Multi.insert(:transaction, Transaction.changeset(%Transaction{}, attrs))
    |> Multi.run(:maybe_update_to_account, fn _, %{transaction: transaction} ->
      if transaction.type in [:deposit, :transfer] do
        to_account_query = Account |> where(id: ^transaction.to_id)

        case Repo.update_all(to_account_query, inc: [balance: transaction.amount]) do
          {1, _} ->
            {:ok, 1}
          {_, _} ->
            {:error, "#{transaction.type} failed due to insuficient balance"}
        end
      else
        {:ok, nil}
      end
    end)
    |> Multi.run(:maybe_update_from_account, fn _, %{transaction: transaction} ->
      if transaction.type in [:withdraw, :transfer] do
        amount = transaction.amount |> Decimal.mult(Decimal.new(-1))
        from_account_query = Account |> where(id: ^transaction.from_id)

        result = try do
          Repo.update_all(from_account_query, inc: [balance: amount])
        rescue
          _e in Postgrex.Error -> {0, 0}
        end

        case result do
          {1, _} ->
            {:ok, 1}
          {_, _} ->
            {:error, "#{transaction.type} failed due to insuficient balance"}
        end
      else
        {:ok, nil}
      end
    end)
    |> Repo.transaction()
    |> case do
      {:ok, %{transaction: transation}} ->
        {:ok, transation}
      {:error, :transaction, changeset, _changes_so_far} ->
        {:error, changeset}
      {:error, _, error, _changes_so_far} when is_binary(error) ->
        {:error, error}
    end
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking transaction changes.

  ## Examples

      iex> change_transaction(transaction)
      %Ecto.Changeset{data: %Transaction{}}

  """
  def change_transaction(%Transaction{} = transaction, attrs \\ %{}) do
    Transaction.changeset(transaction, attrs)
  end
end
