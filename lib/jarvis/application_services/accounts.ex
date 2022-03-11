defmodule Jarvis.ApplicationServices.Accounts do
  @moduledoc """
  Offer services around accounts.
  """

  alias Jarvis.AccountsRepo

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

  @doc """
  Creates a new invitation if an user exists with the provided name.
  """
  def invite_user_to_group(host, invitation_params) do
    user_group = invitation_params["usergroup_id"] |> AccountsRepo.get_user_group!()

    case AccountsRepo.is_group_owner(host, user_group) &&
           AccountsRepo.get_user_by_email(invitation_params["invitee_email"]) do
      false -> nil
      nil -> nil
      invitee -> AccountsRepo.create_invitation(invitation_params, user_group, host, invitee)
    end
  end

  def delete_invitation(invitation_id) do
    case AccountsRepo.get_invitation(invitation_id) do
      {:ok, invitation} ->
        AccountsRepo.delete_invitation(invitation)
    end
  end

  @spec accept_invitation(any, any) :: :ok | {:error, :not_own_invitation}
  def accept_invitation(invitation_id, accepting_user_id) do
    invitation = AccountsRepo.get_invitation!(invitation_id)

    if invitation.invitee.id == accepting_user_id do
      {:ok, _} = AccountsRepo.add_user_to_group(invitation.invitee, invitation.usergroup)
      {:ok, _} = AccountsRepo.delete_invitation(invitation)

      :ok
    else
      {:error, :not_own_invitation}
    end
  end
end
