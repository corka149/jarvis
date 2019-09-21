defmodule Jarvis.ShoppingLists.Vision.Config do
  @moduledoc """
  Represents all necessary configurations for talking to Vision
  """

  alias Jarvis.ShoppingLists.Vision.Config

  defstruct host: "http://127.0.0.1:5000", username: "default_user", password: "default_password"

  def from_env() do
    host = Application.get_env(:jarvis, Jarvis.ShoppingLists.Vision)[:host]
    username = Application.get_env(:jarvis, Jarvis.ShoppingLists.Vision)[:username]
    password = Application.get_env(:jarvis, Jarvis.ShoppingLists.Vision)[:password]
    %Config{host: host, username: username, password: password}
  end

  def build(options \\ []) do
    update_with_options(%Config{}, options)
  end

  defp update_with_options(config, []), do: config

  defp update_with_options(config, [{k, v} | tail] = _options) do
    if Map.has_key?(config, k) do
      Map.put(config, k, v) |> update_with_options(tail)
    else
      update_with_options(config, tail)
    end
  end
end