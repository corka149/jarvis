defmodule Jarvis.ShoppingLists do
  @moduledoc """
  The ShoppingLists context.
  """

  import Ecto.Query, warn: false
  alias Jarvis.Repo

  alias Jarvis.ShoppingLists.ShoppingList

  @doc """
  Returns the list of shoppinglists.

  ## Examples

      iex> list_shoppinglists()
      [%ShoppingList{}, ...]

  """
  def list_shoppinglists do
    Repo.all(ShoppingList)
    |> Repo.preload(:usergroups)
    |> IO.inspect
  end

  @doc """
  Gets a single shopping_list.

  Raises `Ecto.NoResultsError` if the Shopping list does not exist.

  ## Examples

      iex> get_shopping_list!(123)
      %ShoppingList{}

      iex> get_shopping_list!(456)
      ** (Ecto.NoResultsError)

  """
  def get_shopping_list!(id), do: Repo.get!(ShoppingList, id)

  @doc """
  Creates a shopping_list.

  ## Examples

      iex> create_shopping_list(%{field: value}, %{name: "corka"})
      {:ok, %ShoppingList{}}

      iex> create_shopping_list(%{field: bad_value}, %{name: "corka"})
      {:error, %Ecto.Changeset{}}

  """
  def create_shopping_list(attrs \\ %{}, user_group) do
    Ecto.build_assoc(user_group, :shoppinglists)
    |> ShoppingList.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a shopping_list.

  ## Examples

      iex> update_shopping_list(shopping_list, %{field: new_value})
      {:ok, %ShoppingList{}}

      iex> update_shopping_list(shopping_list, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_shopping_list(%ShoppingList{} = shopping_list, attrs) do
    shopping_list
    |> ShoppingList.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a ShoppingList.

  ## Examples

      iex> delete_shopping_list(shopping_list)
      {:ok, %ShoppingList{}}

      iex> delete_shopping_list(shopping_list)
      {:error, %Ecto.Changeset{}}

  """
  def delete_shopping_list(%ShoppingList{} = shopping_list) do
    Repo.delete(shopping_list)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking shopping_list changes.

  ## Examples

      iex> change_shopping_list(shopping_list)
      %Ecto.Changeset{source: %ShoppingList{}}

  """
  def change_shopping_list(%ShoppingList{} = shopping_list) do
    ShoppingList.changeset(shopping_list, %{})
  end
end
