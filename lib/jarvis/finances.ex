defmodule Jarvis.Finances do
  @moduledoc """
  The Finances context.
  """

  import Ecto.Query, warn: false
  alias Jarvis.Repo

  alias Jarvis.Finances.Category
  alias Jarvis.Accounts.User

  @doc """
  Returns the list of categories that belong to an user.
  For security reason it is not possible to get a transaction
  without user_id.

  ## Examples

      iex> list_categories(user)
      [%Category{}, ...]

  """
  def list_categories(%User{} = user) do
    from(cate in Category, where: cate.created_by == ^user.id)
    |> Repo.all()
  end

  @doc """
  Gets a single category.

  Raises `Ecto.NoResultsError` if the Category does not exist.

  ## Examples

      iex> get_category!(123)
      %Category{}

      iex> get_category!(456)
      ** (Ecto.NoResultsError)

  """
  def get_category!(id), do: Repo.get!(Category, id)

  @doc """
  Creates a category.

  ## Examples

      iex> create_category(%{field: value}, creator)
      {:ok, %Category{}}

      iex> create_category(%{field: bad_value}, creator)
      {:error, %Ecto.Changeset{}}

  """
  def create_category(attrs \\ %{}, %User{} = creator) do
    creator
    |> Ecto.build_assoc(:categories)
    |> Category.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a category.

  ## Examples

      iex> update_category(category, %{field: new_value})
      {:ok, %Category{}}

      iex> update_category(category, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_category(%Category{} = category, attrs) do
    category
    |> Category.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a Category.

  ## Examples

      iex> delete_category(category)
      {:ok, %Category{}}

      iex> delete_category(category)
      {:error, %Ecto.Changeset{}}

  """
  def delete_category(%Category{} = category) do
    Repo.delete(category)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking category changes.

  ## Examples

      iex> change_category(category)
      %Ecto.Changeset{source: %Category{}}

  """
  def change_category(%Category{} = category) do
    Category.changeset(category, %{})
  end

  alias Jarvis.Finances.Transaction

  @doc """
  Returns the list of transactions that belong to an user.
  For security reason it is not possible to get a transaction
  without user_id.

  ## Examples

      iex> list_transactions(user)
      [%Transaction{}, ...]

  """
  def list_transactions(%User{} = user) do
    from(transact in Transaction, where: transact.created_by == ^user.id)
    |> Repo.all()
  end

  @doc """
  Gets a single transaction.

  Raises `Ecto.NoResultsError` if the Transaction does not exist.

  ## Examples

      iex> get_transaction!(123)
      %Transaction{}

      iex> get_transaction!(456)
      ** (Ecto.NoResultsError)

  """
  def get_transaction!(id), do: Repo.get!(Transaction, id)

  @doc """
  Creates a transaction.

  ## Examples

      iex> create_transaction(%{field: value}, creator, category)
      {:ok, %Transaction{}}

      iex> create_transaction(%{field: bad_value}, category, category)
      {:error, %Ecto.Changeset{}}

  """
  def create_transaction(attrs \\ %{}, %User{} = creator, %Category{} = category) do
    category_changeset = category |> Ecto.build_assoc(:transactions)

    creator
    |> Ecto.build_assoc(:transactions, category_changeset)
    |> Transaction.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a transaction.

  ## Examples

      iex> update_transaction(transaction, %{field: new_value})
      {:ok, %Transaction{}}

      iex> update_transaction(transaction, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_transaction(%Transaction{} = transaction, attrs) do
    transaction
    |> Transaction.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a Transaction.

  ## Examples

      iex> delete_transaction(transaction)
      {:ok, %Transaction{}}

      iex> delete_transaction(transaction)
      {:error, %Ecto.Changeset{}}

  """
  def delete_transaction(%Transaction{} = transaction) do
    Repo.delete(transaction)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking transaction changes.

  ## Examples

      iex> change_transaction(transaction)
      %Ecto.Changeset{source: %Transaction{}}

  """
  def change_transaction(%Transaction{} = transaction) do
    Transaction.changeset(transaction, %{})
  end
end
