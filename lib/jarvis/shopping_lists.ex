defmodule Jarvis.ShoppingLists do
  @moduledoc """
  The ShoppingLists context.
  """

  import Ecto.Query, warn: false
  alias Jarvis.Repo

  alias Jarvis.ShoppingLists.ShoppingList
  alias Jarvis.ShoppingLists.Item

  @doc """
  Returns the list of shoppinglists.

  ## Examples

      iex> list_shoppinglists()
      [%ShoppingList{}, ...]

  """
  def list_shoppinglists do
    Repo.all(ShoppingList)
    |> Repo.preload(:usergroup)
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
  def get_shopping_list!(id), do: Repo.get!(ShoppingList, id) |> Repo.preload(:usergroup)

  @doc """
  Creates a shopping_list.

  ## Examples

      iex> create_shopping_list(%{field: value}, %{name: "household"})
      {:ok, %ShoppingList{}}

      iex> create_shopping_list(%{field: bad_value}, %{name: "household"})
      {:error, %Ecto.Changeset{}}

  """
  def create_shopping_list(attrs \\ %{}, user_group) do
    user_group
    |> Ecto.build_assoc(:shoppinglists)
    |> ShoppingList.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a shopping_list.

  ## Examples

      iex> update_shopping_list(shopping_list, %{field: new_value}, %{name: "household"})
      {:ok, %ShoppingList{}}

      iex> update_shopping_list(shopping_list, %{field: bad_value}, %{name: "household"})
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

  @doc """
  Creates a new item associated with a shopping list.
  """
  def create_item(attrs \\ %{}, shopping_list) do
    shopping_list
    |> Ecto.build_assoc(:items)
    |> Item.changeset(attrs)
    |> Repo.insert()
  end

  def get_item!(id) do
    Repo.get!(Item, id)
    |> Repo.preload(:shopping_list)
  end

  def delete_item(%Item{} = item) do
    Repo.delete(item)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking item changes.
  (Useful for validation)
  """
  def change_item(item, attrs \\ %{}) do
    Item.changeset(item, attrs)
  end

  @doc """
  Lists all items that belong to a certain shopping list.
  """
  def list_items_by_shopping_list(%ShoppingList{id: id}) do
    Repo.all(from it in Item, where: it.shopping_list_id == ^id)
  end
end
