defmodule Jarvis.ShoppingLists.Vision.Client do

  alias Jarvis.ShoppingLists
  alias Jarvis.ShoppingLists.Vision.Config
  alias JarvisWeb.Api.ShoppingListApiView

  @doc """
  Posts all open shopping lists to Vision.
  """
  def post_open_lists(config \\ %Config{}) do
    %{host: host, username: username, password: password} = config
    credentials = {username, password}
    sl_json = create_shoppinglist_json()
    HTTPotion.post host <> "/v1/shoppinglists/open", [body: sl_json, headers: headers(), basic_auth: credentials]
  end

  defp headers do
    ["Content-Type": "application/json"]
  end

  defp create_shoppinglist_json do
    sl = ShoppingLists.list_open_shoppinglists()
    ShoppingListApiView.render("index.json", %{shopping_lists: sl}) |> Poison.encode!()
  end
end
