defmodule Jarvis.ApplicationServices.Accounts do
  @moduledoc """
  Offer services around accounts.
  """

  alias Jarvis.Repo.Accounts, as: AccountsRepo

  @doc """
  Check credentials for jarvis user
  """
  def verify_user(%{"password" => password, "email" => email}) do
    case email |> AccountsRepo.get_user_by_email() do
      %{provider: "jarvis"} = user -> Argon2.check_pass(user, password)
      _ -> {:error, "Not a jARVIS user"}
    end
  end

  def verify_user(_) do
    {:error, "missing credentials"}
  end
end
