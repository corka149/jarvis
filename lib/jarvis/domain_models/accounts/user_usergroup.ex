defmodule Jarvis.Accounts.UserUsergroup do
  @moduledoc """
  Database module for the entity user_usergroup.
  """
  use Ecto.Schema

  schema "users_usergroups" do
    belongs_to :user_group, Jarvis.Accounts.UserGroup
    belongs_to :user, Jarvis.Accounts.User
  end
end
