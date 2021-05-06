defmodule PacklaneWeb.AccountLiveTest do
  use PacklaneWeb.ConnCase

  import Phoenix.LiveViewTest

  alias Packlane.Banking

  @create_attrs %{balance: "120.5", name: "some name", type: "checking"}
  @update_attrs %{balance: "456.7", name: "some updated name", type: "savings"}
  @invalid_attrs %{balance: nil, name: nil, type: nil}

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

      assert index_live |> element("a", "New Account") |> render_click() =~
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

    test "updates account in listing", %{conn: conn, account: account} do
      {:ok, index_live, _html} = live(conn, Routes.account_index_path(conn, :index))

      assert index_live |> element("#account-#{account.id} a", "Edit") |> render_click() =~
               "Edit Account"

      assert_patch(index_live, Routes.account_index_path(conn, :edit, account))

      assert index_live
             |> form("#account-form", account: @invalid_attrs)
             |> render_change() =~ "can&#39;t be blank"

      {:ok, _, html} =
        index_live
        |> form("#account-form", account: @update_attrs)
        |> render_submit()
        |> follow_redirect(conn, Routes.account_index_path(conn, :index))

      assert html =~ "Account updated successfully"
      assert html =~ "some updated name"
    end

    test "deletes account in listing", %{conn: conn, account: account} do
      {:ok, index_live, _html} = live(conn, Routes.account_index_path(conn, :index))

      assert index_live |> element("#account-#{account.id} a", "Delete") |> render_click()
      refute has_element?(index_live, "#account-#{account.id}")
    end
  end

  describe "Show" do
    setup [:register_and_log_in_user, :create_account]

    test "displays account", %{conn: conn, account: account} do
      {:ok, _show_live, html} = live(conn, Routes.account_show_path(conn, :show, account))

      assert html =~ "Show Account"
      assert html =~ account.name
    end

    test "updates account within modal", %{conn: conn, account: account} do
      {:ok, show_live, _html} = live(conn, Routes.account_show_path(conn, :show, account))

      assert show_live |> element("a", "Edit") |> render_click() =~
               "Edit Account"

      assert_patch(show_live, Routes.account_show_path(conn, :edit, account))

      assert show_live
             |> form("#account-form", account: @invalid_attrs)
             |> render_change() =~ "can&#39;t be blank"

      {:ok, _, html} =
        show_live
        |> form("#account-form", account: @update_attrs)
        |> render_submit()
        |> follow_redirect(conn, Routes.account_show_path(conn, :show, account))

      assert html =~ "Account updated successfully"
      assert html =~ "some updated name"
    end
  end
end
