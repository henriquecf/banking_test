defmodule Packlane.Banking.Transaction do
  use Ecto.Schema
  import Ecto.Changeset

  alias Packlane.Banking.Account

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id
  schema "banking_transactions" do
    field :amount, :decimal
    field :type, Ecto.Enum, values: [:deposit, :withdraw, :transfer]

    belongs_to :to, Account
    belongs_to :from, Account

    timestamps()
  end

  @doc false
  def changeset(transaction, attrs) do
    transaction
    |> cast(attrs, [:type, :amount, :to_id, :from_id])
    |> validate_required([:type, :amount])
    |> validate_number(:amount, greater_than: 0)
    |> type_changeset()
  end

  defp type_changeset(%{valid?: false} = changeset), do: changeset
  defp type_changeset(%{changes: %{type: :deposit}} = changeset) do
    changeset
    |> validate_required([:to_id])
  end
  defp type_changeset(%{changes: %{type: :withdraw}} = changeset) do
    changeset
    |> validate_required([:from_id])
  end
  defp type_changeset(%{changes: %{type: :tranfer}} = changeset) do
    changeset
    |> validate_required([:to_id, :from_id])
  end
end
