defmodule PacklaneWeb.AccountLiveTest do
  use PacklaneWeb.ConnCase

  import Phoenix.LiveViewTest

  alias Packlane.Banking

  @create_attrs %{name: "some name", type: "checking"}
  @invalid_attrs %{name: nil, type: "checking"}

  defp fixture(:account, user) do
    {:ok, account} = Banking.create_account(Map.put(@create_attrs, :user_id, user.id))
    account
  end

  defp create_account(%{user: user}) do
    account = fixture(:account, user)
    %{account: account}
  end

  describe "Index" do
    setup [:register_and_log_in_user, :create_account]

    test "lists all banking_accounts", %{conn: conn, account: account} do
      {:ok, _index_live, html} = live(conn, Routes.account_index_path(conn, :index))

      assert html =~ "Listing Banking accounts"
      assert html =~ account.name
    end

    test "saves new account", %{conn: conn} do
      {:ok, index_live, _html} = live(conn, Routes.account_index_path(conn, :index))

      assert index_live |> element("a", "+ Account") |> render_click() =~
               "New Account"

      assert_patch(index_live, Routes.account_index_path(conn, :new))

      assert index_live
             |> form("#account-form", account: @invalid_attrs)
             |> render_change() =~ "can&#39;t be blank"

      {:ok, _, html} =
        index_live
        |> form("#account-form", account: @create_attrs)
        |> render_submit()
        |> follow_redirect(conn, Routes.account_index_path(conn, :index))

      assert html =~ "Account created successfully"
      assert html =~ "some name"
    end
  end

  describe "Show" do
    setup [:register_and_log_in_user, :create_account]

    test "displays account", %{conn: conn, account: account} do
      {:ok, _show_live, html} = live(conn, Routes.account_show_path(conn, :show, account))

      assert html =~ "Show Account"
      assert html =~ account.name
    end
  end
end
