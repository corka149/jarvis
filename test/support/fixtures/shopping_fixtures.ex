defmodule Jarvis.ShoppingFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `Jarvis.Shopping` context.
  """

  @doc """
  Generate a list.
  """
  def list_fixture(attrs \\ %{}) do
    {:ok, list} =
      attrs
      |> Enum.into(%{
        purchase_at: ~D[2026-02-07],
        status: :open,
        title: "some title"
      })
      |> Jarvis.Shopping.create_list()

    list
  end
end
