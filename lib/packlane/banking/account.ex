defmodule Packlane.Banking.Account do
  use Ecto.Schema
  import Ecto.Changeset

  @primary_key {:id, :binary_id, autogenerate: true}
  schema "banking_accounts" do
    field :balance, :decimal, default: Decimal.new(0)
    field :name, :string
    field :type, Ecto.Enum, values: [:checking, :savings]

    belongs_to :user, Packlane.Accounts.User

    timestamps()
  end

  @doc false
  def changeset(account, attrs) do
    account
    |> cast(attrs, [:name, :type, :user_id])
    |> validate_required([:name, :type, :user_id])
  end
end
