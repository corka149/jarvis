defmodule Jarvis.FinancesTest do
  use Jarvis.DataCase

  alias Jarvis.Finances
  alias Jarvis.Accounts

  @valid_attrs_user %{
    email: "someemail@test.xyz",
    name: "some name",
    provider: "some provider",
    token: "some token"
  }

  describe "categories" do
    alias Jarvis.Finances.Category

    @valid_attrs %{name: "some name"}
    @update_attrs %{name: "some updated name"}
    @invalid_attrs %{name: nil}

    def category_fixture(attrs \\ %{}) do
      {:ok, creator} = Jarvis.Accounts.create_user(@valid_attrs_user)

      {:ok, category} =
        attrs
        |> Enum.into(@valid_attrs)
        |> Finances.create_category(creator)

      category
    end

    test "list_categories/0 returns all categories" do
      category = category_fixture()
      user = Accounts.get_user!(category.created_by)
      assert Finances.list_categories(user) == [category]
    end

    test "get_category!/1 returns the category with given id" do
      category = category_fixture()
      assert Finances.get_category!(category.id) == category
    end

    test "create_category/1 with valid data creates a category" do
      {:ok, creator} = Jarvis.Accounts.create_user(@valid_attrs_user)

      assert {:ok, %Category{} = category} = Finances.create_category(@valid_attrs, creator)
      assert category.name == "some name"
    end

    test "create_category/1 with invalid data returns error changeset" do
      {:ok, creator} = Jarvis.Accounts.create_user(@valid_attrs_user)
      assert {:error, %Ecto.Changeset{}} = Finances.create_category(@invalid_attrs, creator)
    end

    test "update_category/2 with valid data updates the category" do
      category = category_fixture()
      assert {:ok, %Category{} = category} = Finances.update_category(category, @update_attrs)
      assert category.name == "some updated name"
    end

    test "update_category/2 with invalid data returns error changeset" do
      category = category_fixture()
      assert {:error, %Ecto.Changeset{}} = Finances.update_category(category, @invalid_attrs)
      assert category == Finances.get_category!(category.id)
    end

    test "delete_category/1 deletes the category" do
      category = category_fixture()
      assert {:ok, %Category{}} = Finances.delete_category(category)
      assert_raise Ecto.NoResultsError, fn -> Finances.get_category!(category.id) end
    end

    test "change_category/1 returns a category changeset" do
      category = category_fixture()
      assert %Ecto.Changeset{} = Finances.change_category(category)
    end
  end

  describe "transactions" do
    alias Jarvis.Finances.Transaction

    @valid_attrs %{description: "some description", executed_on: ~N[2010-04-17 14:00:00], recurring: true, value: 120.5}
    @update_attrs %{description: "some updated description", executed_on: ~N[2011-05-18 15:01:01], recurring: false, value: 456.7}
    @invalid_attrs %{description: nil, executed_on: nil, recurring: nil, value: nil}

    @valid_attrs_category %{name: "some name"}

    def transaction_fixture(attrs \\ %{}) do
      {:ok, creator} = Jarvis.Accounts.create_user(@valid_attrs_user)
      {:ok, category} = Finances.create_category(@valid_attrs_category, creator)

      {:ok, transaction} =
        attrs
        |> Enum.into(@valid_attrs)
        |> Finances.create_transaction(creator, category)

      transaction
    end

    setup _ do
      {:ok, creator} = Jarvis.Accounts.create_user(@valid_attrs_user)
      {:ok, category} = Finances.create_category(@valid_attrs_category, creator)
      %{creator: creator, category: category}
    end

    test "list_transactions/0 returns all transactions" do
      transaction = transaction_fixture()
      user = Accounts.get_user!(transaction.created_by)
      assert Finances.list_transactions(user) == [transaction]
    end

    test "get_transaction!/1 returns the transaction with given id" do
      transaction = transaction_fixture()
      assert Finances.get_transaction!(transaction.id) == transaction
    end

    test "create_transaction/1 with valid data creates a transaction", %{creator: creator, category: category} do
      assert {:ok, %Transaction{} = transaction} = Finances.create_transaction(@valid_attrs, creator, category)
      assert transaction.description == "some description"
      assert transaction.executed_on == ~N[2010-04-17 14:00:00]
      assert transaction.recurring == true
      assert transaction.value == 120.5
    end

    test "create_transaction/1 with invalid data returns error changeset", %{creator: creator, category: category} do
      assert {:error, %Ecto.Changeset{}} = Finances.create_transaction(@invalid_attrs, creator, category)
    end

    test "update_transaction/2 with valid data updates the transaction" do
      transaction = transaction_fixture()
      assert {:ok, %Transaction{} = transaction} = Finances.update_transaction(transaction, @update_attrs)
      assert transaction.description == "some updated description"
      assert transaction.executed_on == ~N[2011-05-18 15:01:01]
      assert transaction.recurring == false
      assert transaction.value == 456.7
    end

    test "update_transaction/2 with invalid data returns error changeset" do
      transaction = transaction_fixture()
      assert {:error, %Ecto.Changeset{}} = Finances.update_transaction(transaction, @invalid_attrs)
      assert transaction == Finances.get_transaction!(transaction.id)
    end

    test "delete_transaction/1 deletes the transaction" do
      transaction = transaction_fixture()
      assert {:ok, %Transaction{}} = Finances.delete_transaction(transaction)
      assert_raise Ecto.NoResultsError, fn -> Finances.get_transaction!(transaction.id) end
    end

    test "change_transaction/1 returns a transaction changeset" do
      transaction = transaction_fixture()
      assert %Ecto.Changeset{} = Finances.change_transaction(transaction)
    end
  end
end
