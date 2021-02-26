# For development

valid_attrs_user = %{
  email: "ash@test.xyz",
  name: "Ash",
  provider: "jarvis",
  token: "jarvis",
  password: "THIS_15_password"
}

case Jarvis.Accounts.create_user(valid_attrs_user) do
  {:ok, _} -> IO.puts("=====\nCreate user Ash with credentials 'ash@test.xyz' / 'THIS_15_password'\n=====")
  error -> IO.inspect(error)
end
