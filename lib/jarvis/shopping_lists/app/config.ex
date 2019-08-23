defmodule Jarvis.ShoppingLists.App.Config do
  @moduledoc """
  Represents all necessary configurations for talking to Vision
  """

  alias Jarvis.ShoppingLists.App.Config

  defstruct host: "http://127.0.0.1:5000", username: "default_user", password: "default_password"

  def build(options \\ []) do
    update_with_options(%Config{}, options)
  end

  defp update_with_options(config, []), do: config

  defp update_with_options(config, [{k, v} | tail] = _options) do
    if Map.has_key?(config, k) do
      Map.put(config, k, v)
    end
    update_with_options(config, tail)
  end
end
