defmodule Jarvis.TestHelper do
  @moduledoc """
  Collection of functions for testing ONLY.
  """

  @doc """
  Updates a map with user params with a unique email address
  """
  def update_with_unique_email(user) do
    email = Integer.to_string(:random.uniform(10_000_000)) <> user.email
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
      provider: "some provider",
      token: "some token"
    }

    {:ok, user} =
      update_with_unique_email(valid_attrs_user)
      |> Jarvis.Accounts.create_user()

    user
  end

  def gen_test_data(:user_group) do
    valid_attrs_group = %{name: "some name"}
    user = gen_test_data(:user)

    {:ok, user_group} =
      %{}
      |> Enum.into(valid_attrs_group)
      |> Jarvis.Accounts.create_user_group(user)

    Jarvis.Repo.preload(user_group, :user)
  end
end
