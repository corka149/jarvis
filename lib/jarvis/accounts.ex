defmodule Jarvis.Accounts do
  @moduledoc """
  The Accounts context.
  """

  import Ecto.Query, warn: false
  alias Jarvis.Repo

  alias Jarvis.Accounts.User

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
  def get_user!(id), do: Repo.get!(User, id)

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
  Gets a single user_group.

  Raises `Ecto.NoResultsError` if the User group does not exist.

  ## Examples

      iex> get_user_group!(123)
      %UserGroup{}

      iex> get_user_group!(456)
      ** (Ecto.NoResultsError)

  """
  def get_user_group!(id), do: Repo.get!(UserGroup, id)

  @doc """
  Creates a user_group.

  ## Examples

      iex> create_user_group(%{field: value})
      {:ok, %UserGroup{}}

      iex> create_user_group(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_user_group(attrs \\ %{}) do
    %UserGroup{}
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
end
