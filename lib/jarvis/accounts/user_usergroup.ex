defmodule Jarvis.Accounts.UserUsergroup do
  use Ecto.Schema

  schema "users_usergroups" do
    belongs_to :usergroup, Jarvis.Accounts.UserGroup
    belongs_to :user, Jarvis.Accounts.User
  end

end
