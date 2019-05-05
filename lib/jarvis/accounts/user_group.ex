defmodule Jarvis.Accounts.UserGroup do
  use Ecto.Schema
  import Ecto.Changeset

  schema "usergroups" do
    field :name, :string
    belongs_to :user, Jarvis.Accounts.UserGroup

    timestamps()
  end

  @doc false
  def changeset(user_group, attrs) do
    user_group
    |> cast(attrs, [:name])
    |> validate_required([:name])
  end
end
