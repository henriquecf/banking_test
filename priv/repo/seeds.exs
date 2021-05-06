# Script for populating the database. You can run it as:
#
#     mix run priv/repo/seeds.exs
#
# Inside the script, you can read and write to any of your
# repositories directly:
#
#     Packlane.Repo.insert!(%Packlane.SomeSchema{})
#
# We recommend using the bang functions (`insert!`, `update!`
# and so on) as they will fail if something goes wrong.

{:ok, user} = Packlane.Accounts.register_user(%{email: "pack@lane.com", password: "Asdf12341234"})

{:ok, checking_account} = Packlane.Banking.create_account(%{name: "My first checking account", balance: "50", user_id: user.id, type: "checking"})
{:ok, savings_account} = Packlane.Banking.create_account(%{name: "My first savings account", balance: "2200", user_id: user.id, type: "savings"})
