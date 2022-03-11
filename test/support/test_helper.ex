defmodule Jarvis.TestHelper do
  @moduledoc """
  Collection of functions for testing ONLY.
  """

  alias Jarvis.AccountsRepo

  @doc """
  Updates a map with user params with a unique email address
  """
  def update_with_unique_email(user) do
    email = Integer.to_string(:rand.uniform(10_000_000)) <> user.email
    %{user | email: email}
  end

  @doc """
  Generate test data for other entites.
  """
  def gen_test_data(data_type)

  def gen_test_data(:user) do
    valid_attrs_user = %{
      email: "someemail@test.xyz",
      name: "some name",
      provider: "jarvis",
      token: "some token",
      password: "THIS_15_password"
    }

    {:ok, user} =
      update_with_unique_email(valid_attrs_user)
      |> AccountsRepo.create_user()

    user
  end

  def gen_test_data(:user_group) do
    valid_attrs_group = %{name: "some name"}
    user = gen_test_data(:user)

    {:ok, user_group} =
      %{}
      |> Enum.into(valid_attrs_group)
      |> AccountsRepo.create_user_group(user)

    Jarvis.Repo.preload(user_group, :user)
  end
end
