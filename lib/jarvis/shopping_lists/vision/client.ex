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

    case create_shoppinglist_json() do
      {:ok, sl_json} ->
        HTTPotion.post(host <> "/v1/shoppinglists/open",
          body: sl_json,
          headers: headers(),
          basic_auth: credentials
        )

      _ ->
        nil
    end
  end

  defp headers do
    ["Content-Type": "application/json"]
  end

  @doc """
  Creates a json with all open shipping lists for the current day.
  """
  def create_shoppinglist_json do
    s_lists = ShoppingLists.list_open_shoppinglists_of_today()

    if length(s_lists) > 0 do
      sl_json =
        ShoppingListApiView.render("index.json", %{shopping_lists: s_lists}) |> Poison.encode!()

      {:ok, sl_json}
    else
      {:empty, "no_open_lists_for_today"}
    end
  end
end
