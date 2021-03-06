defmodule Jarvis.Accounts.User do
  @moduledoc """
  Database module for the entity user.
  """
  use Ecto.Schema

  import Ecto.Changeset

  require Logger

  schema "users" do
    field :email, :string
    field :name, :string
    field :provider, :string
    field :token, :string
    field :password, :string
    field :password_hash, :string
    has_many :usergroups, Jarvis.Accounts.UserGroup
    many_to_many :member_of, Jarvis.Accounts.UserGroup, join_through: "users_usergroups"
    has_many :created_invitations, Jarvis.Accounts.Invitation, foreign_key: :host_id
    has_many :received_invitations, Jarvis.Accounts.Invitation, foreign_key: :invitee_id
    field :default_language, :string

    timestamps()
  end

  @doc false
  def changeset(user, attrs) do
    attrs = trim_values(attrs)

    user
    |> cast(attrs, [:name, :email, :provider, :token, :default_language, :password])
    |> validate_format(:email, email_validation())
    |> validate_required([:name, :email, :provider, :token])
    |> unique_constraint(:email)
    |> validate_jarvis_password(user)
  end

  ## Validate password

  # Existing jarvis user
  defp validate_jarvis_password(%{changes: changes} = changeset, %{provider: "jarvis"} = user) do
    if password_in_changes?(changes) or not has_encrypted_password(user) do
      Logger.info("Detected jarvis as provider")
      do_validate_jarvis_password(changeset)
    else
      changeset
    end
  end

  # New jarvis user
  defp validate_jarvis_password(%{changes: %{provider: "jarvis"} = changes} = changeset, user) do
    if password_in_changes?(changes) or not has_encrypted_password(user) do
      Logger.info("Detected jarvis as provider")
      do_validate_jarvis_password(changeset)
    else
      changeset
    end
  end

  # Not jarvis user
  defp validate_jarvis_password(changeset, _user) do
    changeset
  end

  defp do_validate_jarvis_password(changeset) do
    validate_length(changeset, :password, min: 8, max: 50)
    |> validate_required([:password])
    |> validate_format(:password, password_validation(), message: password_rules())
    |> put_pass_hash()
  end

  defp put_pass_hash(%Ecto.Changeset{valid?: true, changes: %{password: password}} = changeset) do
    changeset = change(changeset, Argon2.add_hash(password))
    changes = Map.put(changeset.changes, :password, "")
    %{changeset | changes: changes}
  end

  defp put_pass_hash(changeset), do: changeset

  defp has_encrypted_password(%{password_hash: "$argon2id$" <> _} = _user), do: true
  defp has_encrypted_password(_user), do: false

  defp password_in_changes?(changes) do
    str_password? = Map.has_key?(changes, "password") and Map.get(changes, "password") != nil
    keyword_password? = Map.has_key?(changes, :password) and Map.get(changes, :password) != nil
    str_password? or keyword_password?
  end

  defp password_validation do
    # Simple and primitive but it is something
    ~r/^(?=.*[a-z])(?=.*[A-Z])(?=.*[0-9])(?=.*[!@#\$%\^&\*\-\_])(?=.{8,})/
  end

  defp password_rules do
    "Must contain at least 1 lowercase and uppercase alphabetical character; Must contain at least 1 numeric character; Must contain at least one special character;"
  end

  ## E-Mail validation

  defp email_validation do
    ~r/^[_a-z0-9-]+(.[a-z0-9-]+)@[a-z0-9-]+(.[a-z0-9-]+)*(.[a-z]{2,4})$/
  end

  ## Trim values

  defp trim_values(%{} = attrs), do: Enum.map(attrs, &trim_value/1) |> Map.new()
  defp trim_values(attrs), do: attrs

  defp trim_value({_key, nil} = attr), do: attr
  defp trim_value({key, value}) when is_binary(value), do: {key, String.trim(value)}
  defp trim_value(attr), do: attr
end
