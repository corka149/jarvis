defmodule Jarvis.Accounts do
  @moduledoc """
  The Accounts context.
  """

  import Ecto.Query, warn: false
  alias Jarvis.Repo

  alias Jarvis.Accounts.User
  alias Jarvis.Accounts.UserGroup
  alias Jarvis.Accounts.UserUsergroup

  @doc """
  Returns the list of users.

  ## Examples

      iex> list_users()
      [%User{}, ...]

  """
  def list_users do
    Repo.all(User)
  end

  @doc """
  Gets a single user.

  Raises `Ecto.NoResultsError` if the User does not exist.

  ## Examples

      iex> get_user!(123)
      %User{}

      iex> get_user!(456)
      ** (Ecto.NoResultsError)

  """
  def get_user!(id) do
    Repo.get!(User, id)
    |> Repo.preload([:usergroups, :member_of])
  end

  @doc """
  Fetches a single user by name.
  """
  def get_user_by_name(name) do
    Repo.get_by(User, name: name)
  end

  @doc """
  Creates a user.

  ## Examples

      iex> create_user(%{field: value})
      {:ok, %User{}}

      iex> create_user(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_user(attrs \\ %{}) do
    %User{}
    |> User.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a user.

  ## Examples

      iex> update_user(user, %{field: new_value})
      {:ok, %User{}}

      iex> update_user(user, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_user(%User{} = user, attrs) do
    user
    |> User.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a User.

  ## Examples

      iex> delete_user(user)
      {:ok, %User{}}

      iex> delete_user(user)
      {:error, %Ecto.Changeset{}}

  """
  def delete_user(%User{} = user) do
    Repo.delete(user)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking user changes.

  ## Examples

      iex> change_user(user)
      %Ecto.Changeset{source: %User{}}

  """
  def change_user(%User{} = user) do
    User.changeset(user, %{})
  end

  alias Jarvis.Accounts.UserGroup

  @doc """
  Returns the list of usergroups.

  ## Examples

      iex> list_usergroups()
      [%UserGroup{}, ...]

  """
  def list_usergroups do
    Repo.all(UserGroup)
  end

  @doc """
  Returns all user groups owned by a specific user.

  """
  def list_usergroups_by_owner(%User{} = user) do
    Repo.all(from ug in UserGroup, where: ug.user_id == ^user.id)
  end

  @doc """
  Returns all user groups in which an user has membership.
  """
  def list_usergroups_by_membership(user) do
    from(u_ug in UserUsergroup, where: u_ug.user_id == ^user.id)
    |> Repo.all()
    |> Repo.preload([:user_group, :user])
  end

  def list_usergroups_by_membership_or_owner(%User{} = user) do
    owner_groups =
      list_usergroups_by_owner(user)
      |> Enum.map(fn ug -> {ug.name, ug.id} end)

    membership_groups =
      list_usergroups_by_membership(user)
      |> Enum.map(fn uug -> {uug.user_group.name, uug.user_group.id} end)

    owner_groups ++ membership_groups
  end

  @doc """
  Gets a single user_group.

  Raises `Ecto.NoResultsError` if the User group does not exist.

  ## Examples

      iex> get_user_group!(123)
      %UserGroup{}

      iex> get_user_group!(456)
      ** (Ecto.NoResultsError)

  """
  def get_user_group!(id), do: Repo.get!(UserGroup, id) |> Repo.preload(:user)

  @doc """
  Creates a user_group.

  ## Examples

      iex> create_user_group(%{field: value}, user)
      {:ok, %UserGroup{}}

      iex> create_user_group(%{field: bad_value}, user)
      {:error, %Ecto.Changeset{}}

  """
  def create_user_group(attrs \\ %{}, user) do
    Ecto.build_assoc(user, :usergroups)
    |> UserGroup.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a user_group.

  ## Examples

      iex> update_user_group(user_group, %{field: new_value})
      {:ok, %UserGroup{}}

      iex> update_user_group(user_group, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_user_group(%UserGroup{} = user_group, attrs) do
    user_group
    |> UserGroup.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a UserGroup.

  ## Examples

      iex> delete_user_group(user_group)
      {:ok, %UserGroup{}}

      iex> delete_user_group(user_group)
      {:error, %Ecto.Changeset{}}

  """
  def delete_user_group(%UserGroup{} = user_group) do
    Repo.delete(user_group)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking user_group changes.

  ## Examples

      iex> change_user_group(user_group)
      %Ecto.Changeset{source: %UserGroup{}}

  """
  def change_user_group(%UserGroup{} = user_group) do
    UserGroup.changeset(user_group, %{})
  end

  @doc """
  Adds an user to a group and make him to a group member.
  """
  def add_user_to_group(%User{} = user, %UserGroup{} = group) do
    user
    |> Repo.preload(:member_of)
    |> Ecto.Changeset.change()
    |> Ecto.Changeset.put_assoc(:member_of, [group])
    |> Repo.update()
  end

  @doc """
  Deletes the membership from an user to a group.
  """
  def delete_user_from_group(%User{} = user, %UserGroup{} = group) do
    query =
      from(u_ug in UserUsergroup,
        where: u_ug.user_id == ^user.id and u_ug.user_group_id == ^group.id
      )

    case Repo.delete_all(query) do
      {rows, _} when rows > 0 -> :ok
      _ -> :error
    end
  end

  alias Jarvis.Accounts.Invitation

  @doc """
  Returns the list of invitations.

  ## Examples

      iex> list_invitations()
      [%Invitation{}, ...]

  """
  def list_invitations do
    Repo.all(Invitation)
  end

  def list_invitations_by_host(%User{} = user) do
    from(inv in Invitation, where: inv.host_id == ^user.id)
    |> Repo.all()
    |> Repo.preload([:usergroup, :invitee, :host])
  end

  def list_initations_by_invitee(%User{} = user) do
    from(inv in Invitation, where: inv.invitee_id == ^user.id)
    |> Repo.all()
    |> Repo.preload([:usergroup, :invitee, :host])
  end

  @doc """
  Gets a single invitation.

  Raises `Ecto.NoResultsError` if the Invitation does not exist.

  ## Examples

      iex> get_invitation!(123)
      %Invitation{}

      iex> get_invitation!(456)
      ** (Ecto.NoResultsError)

  """
  def get_invitation!(id),
    do: Repo.get!(Invitation, id) |> Repo.preload([:usergroup, :invitee, :host])

  @doc """
  Gets a single invitation.

  ## Examples

      iex> get_invitation!(123)
      {:ok, %Invitation{}}

      iex> get_invitation!(456)
      {:error, "No matching record found"}

  """
  def get_invitation(id) do
    case Repo.get(Invitation, id) do
      nil -> {:error, "No matching record found"}
      invitation -> {:ok, invitation |> Repo.preload([:usergroup, :invitee, :host])}
    end
  end

  @doc """
  Creates a invitation.

  ## Examples

      iex> create_invitation(%{field: value}, %UserGroup{} = user_group, %User{} = host, %User{} = invitee)
      {:ok, %Invitation{}}

      iex> create_invitation(%{field: bad_value}, %UserGroup{} = user_group, %User{} = host, %User{} = invitee)
      {:error, %Ecto.Changeset{}}

  """
  def create_invitation(
        attrs \\ %{},
        %UserGroup{} = user_group,
        %User{} = host,
        %User{} = invitee
      ) do
    changeset = Ecto.build_assoc(user_group, :invitations)
    changeset = Ecto.build_assoc(invitee, :received_invitations, changeset)

    Ecto.build_assoc(host, :created_invitations, changeset)
    |> Invitation.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a invitation.

  ## Examples

      iex> update_invitation(invitation, %{field: new_value})
      {:ok, %Invitation{}}

      iex> update_invitation(invitation, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_invitation(%Invitation{} = invitation, attrs) do
    invitation
    |> Invitation.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a Invitation.

  ## Examples

      iex> delete_invitation(invitation)
      {:ok, %Invitation{}}

      iex> delete_invitation(invitation)
      {:error, %Ecto.Changeset{}}

  """
  def delete_invitation(%Invitation{} = invitation) do
    Repo.delete(invitation)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking invitation changes.

  ## Examples

      iex> change_invitation(invitation)
      %Ecto.Changeset{source: %Invitation{}}

  """
  def change_invitation(%Invitation{} = invitation) do
    Invitation.changeset(invitation, %{})
  end

  @doc """
  Checks if an user is owner of an user group.
  """
  @spec is_group_owner(Jarvis.Accounts.User.t(), Jarvis.Accounts.UserGroup.t()) :: boolean
  def is_group_owner(%Jarvis.Accounts.User{} = host, %Jarvis.Accounts.UserGroup{} = user_group) do
    host.id == user_group.user.id
  end
end
