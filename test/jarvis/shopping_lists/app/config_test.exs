defmodule Jarvis.ShoppingLists.App.ConfigTest do
  use ExUnit.Case

  alias Jarvis.ShoppingLists.App.Config

  test "change config" do
    config = Config.build [host: "https://httpbin.org", username: "Alice", password: "secret"]

    assert %Config{
      host: "https://httpbin.org",
      password: "secret",
      username: "Alice"
    } = config
  end

end
