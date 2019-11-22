defmodule Jarvis.TestHelper do
  @doc """
  Updates a map with user params with a unique email address
  """
  def update_with_unique_email(user) do
    email = Integer.to_string(:random.uniform(10_000_000)) <> user.email
    %{user | email: email}
  end
end
