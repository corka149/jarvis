defmodule Jarvis.ShoppingLists do
  @moduledoc """
  The ShoppingLists context.
  """

  import Ecto.Query, warn: false
  alias Jarvis.Repo

  alias Jarvis.Accounts.User
  alias Jarvis.ShoppingLists.Product
  alias Jarvis.ShoppingLists.ShoppingList

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
  Returns all lists that an user created and all lists that
  belongs to a group in which the user is a member.
  """
  def list_shoppinglists_for_user(%User{} = user) do
    group_ids = Enum.map(user.usergroups, & &1.id) ++ Enum.map(user.member_of, & &1.id)

    from(sl in ShoppingList, where: sl.belongs_to in ^group_ids)
    |> Repo.all()
    |> Repo.preload(:usergroup)
  end

  @doc """
  Returns all shopping lists which are not done for a specific user.
  """
  def list_open_shoppinglists(%User{} = user) do
    Jarvis.ShoppingLists.list_shoppinglists_for_user(user)
    |> Enum.filter(fn sl -> !sl.done end)
  end

  @doc """
  Returns every open shopping list.
  """
  def list_open_shoppinglists_of_today do
    from(sl in ShoppingList, where: not sl.done and sl.planned_for == ^Date.utc_today())
    |> Repo.all()
    |> Repo.preload([:usergroup, :items])
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
    case user_group
         |> Ecto.build_assoc(:shoppinglists)
         |> ShoppingList.changeset(attrs)
         |> Repo.insert() do
      {:ok, shopping_list} -> {:ok, shopping_list |> Repo.preload(:usergroup)}
      changeset -> changeset
    end
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
  Deletes a ShoppingList and its items.

  ## Examples

      iex> delete_shopping_list(shopping_list)
      {:ok, %ShoppingList{}}

      iex> delete_shopping_list(shopping_list)
      {:error, %Ecto.Changeset{}}

  """
  def delete_shopping_list(%ShoppingList{} = shopping_list) do
    from(item in Product, where: item.shopping_list_id == ^shopping_list.id)
    |> Repo.delete_all()

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
    |> Product.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates an existing item associated with a shopping list.
  """
  def update_item(%Product{} = item, attrs) do
    item
    |> Product.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Creates a new item or update an existing one when attrs contains
  an ID.
  """
  def create_or_update_item(attrs, shopping_list) do
    case attrs do
      %{"id" => ""} -> create_item(attrs, shopping_list)
      %{"id" => id} -> get_item!(id) |> update_item(attrs)
      _ -> create_item(attrs, shopping_list)
    end
  end

  def get_item!(id) do
    Repo.get!(Product, id)
    |> Repo.preload(:shopping_list)
  end

  def delete_item(%Product{} = item) do
    Repo.delete(item)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking item changes.
  (Useful for validation)
  """
  def change_item(item, attrs \\ %{}) do
    Product.changeset(item, attrs)
  end

  @doc """
  Lists all items that belong to a certain shopping list.
  """
  def list_items_by_shopping_list(%ShoppingList{id: id}) do
    Repo.all(from it in Product, where: it.shopping_list_id == ^id)
  end
end
