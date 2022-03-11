defmodule JarvisWeb.PlaceLiveTest do
  use JarvisWeb.ConnCase

  import Phoenix.LiveViewTest
  import Jarvis.TestHelper

  alias Jarvis.InventoryRepo

  @create_attrs %{name: "some name", belongs_to: nil}
  @update_attrs %{name: "some updated name", belongs_to: nil}
  @invalid_attrs %{name: nil, belongs_to: nil}

  defp fixture(:place, user_group) do
    {:ok, place} = InventoryRepo.create_place(@create_attrs, user_group)
    place
  end

  defp fixture(:user_group) do
    gen_test_data(:user_group)
  end

  defp create_place(_) do
    group = fixture(:user_group)
    place = fixture(:place, group)
    %{place: place, user_group: group}
  end

  defp authorize(conn, group) do
    conn
    |> Phoenix.ConnTest.init_test_session(user_id: group.user.id)
  end

  describe "Index" do
    setup [:create_place]

    test "lists all places", %{conn: conn, place: place, user_group: group} do
      conn = authorize(conn, group)

      {:ok, _index_live, html} = live(conn, Routes.place_index_path(conn, :index))

      assert html =~ "Listing Places"
      assert html =~ place.name
    end

    test "saves new place", %{conn: conn, user_group: group} do
      conn = authorize(conn, group)

      {:ok, index_live, _html} = live(conn, Routes.place_index_path(conn, :index))

      assert index_live |> element("a", "add") |> render_click() =~
               "New Place"

      assert_patch(index_live, Routes.place_index_path(conn, :new))

      assert index_live
             |> form("#place-form", place: %{@invalid_attrs | belongs_to: group.id})
             |> render_change() =~ "can&#39;t be blank"

      {:ok, _, html} =
        index_live
        |> form("#place-form", place: %{@create_attrs | belongs_to: group.id})
        |> render_submit()
        |> follow_redirect(conn, Routes.place_index_path(conn, :index))

      assert html =~ "Place created successfully"
      assert html =~ "some name"
    end

    test "updates place in listing", %{conn: conn, place: place, user_group: group} do
      conn = authorize(conn, group)

      {:ok, index_live, _html} = live(conn, Routes.place_index_path(conn, :index))

      assert index_live |> element("#place-#{place.id} a", "create") |> render_click() =~
               "Edit Place"

      assert_patch(index_live, Routes.place_index_path(conn, :edit, place))

      assert index_live
             |> form("#place-form", place: %{@invalid_attrs | belongs_to: group.id})
             |> render_change() =~ "can&#39;t be blank"

      {:ok, _, html} =
        index_live
        |> form("#place-form", place: %{@update_attrs | belongs_to: group.id})
        |> render_submit()
        |> follow_redirect(conn, Routes.place_index_path(conn, :index))

      assert html =~ "Place updated successfully"
      assert html =~ "some updated name"
    end

    test "deletes place in listing", %{conn: conn, place: place, user_group: group} do
      conn = authorize(conn, group)

      {:ok, index_live, _html} = live(conn, Routes.place_index_path(conn, :index))

      assert index_live |> element("#place-#{place.id} a", "delete") |> render_click()
      refute has_element?(index_live, "#place-#{place.id}")
    end
  end

  describe "Show" do
    setup [:create_place]

    test "displays place", %{conn: conn, place: place, user_group: group} do
      conn = authorize(conn, group)
      {:ok, _show_live, html} = live(conn, Routes.place_show_path(conn, :show, place))

      assert html =~ "Show place"
      assert html =~ place.name
    end
  end
end
