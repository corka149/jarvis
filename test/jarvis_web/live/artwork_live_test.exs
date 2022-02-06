defmodule JarvisWeb.ArtworkLiveTest do
  use JarvisWeb.ConnCase

  import Phoenix.LiveViewTest

  alias Jarvis.Inventory
  import Jarvis.TestHelper

  @create_attrs %{
    name: "some name"
  }
  @update_attrs %{
    name: "some updated name"
  }
  @invalid_attrs %{name: nil}

  @valid_attrs_isle %{name: "some name"}

  def fixture(:artwork) do
    user_group = gen_test_data(:user_group)
    {:ok, isle} = Inventory.create_isle(@valid_attrs_isle, user_group)

    {:ok, artwork} = Inventory.create_artwork(@create_attrs, isle)
    artwork
  end

  def fixture(:isle) do
    user_group = gen_test_data(:user_group)
    {:ok, isle} = Inventory.create_isle(@valid_attrs_isle, user_group)
    isle
  end

  setup %{conn: conn} do
    isle = fixture(:isle)
    user = gen_test_data(:user)

    conn =
      conn
      |> Phoenix.ConnTest.init_test_session(user_id: user.id)

    {:ok, conn: conn, isle: isle}
  end

  defp create_artwork(_) do
    artwork = fixture(:artwork)
    %{artwork: artwork}
  end

  describe "Index" do
    setup [:create_artwork]

    test "lists all artworks", %{conn: conn, artwork: artwork} do
      {:ok, _index_live, html} = live(conn, Routes.artwork_index_path(conn, :index))

      assert html =~ "Listing Artworks"
      assert html =~ artwork.name
    end

    test "saves new artwork", %{conn: conn} do
      {:ok, index_live, _html} = live(conn, Routes.artwork_index_path(conn, :index))

      assert index_live |> element("a", "add") |> render_click() =~
               "New Artwork"

      assert_patch(index_live, Routes.artwork_index_path(conn, :new))

      assert index_live
             |> form("#artwork-form", artwork: @invalid_attrs)
             |> render_change() =~ "can&#39;t be blank"

      {:ok, _, html} =
        index_live
        |> form("#artwork-form", artwork: @create_attrs)
        |> render_submit()
        |> follow_redirect(conn, Routes.artwork_index_path(conn, :index))

      assert html =~ "Artwork created successfully"
      assert html =~ "some name"
    end

    test "updates artwork in listing", %{conn: conn, artwork: artwork} do
      {:ok, index_live, _html} = live(conn, Routes.artwork_index_path(conn, :index))

      assert index_live |> element("#artwork-#{artwork.id} a", "create") |> render_click() =~
               "Edit Artwork"

      assert_patch(index_live, Routes.artwork_index_path(conn, :edit, artwork))

      assert index_live
             |> form("#artwork-form", artwork: @invalid_attrs)
             |> render_change() =~ "can&#39;t be blank"

      {:ok, _, html} =
        index_live
        |> form("#artwork-form", artwork: @update_attrs)
        |> render_submit()
        |> follow_redirect(conn, Routes.artwork_index_path(conn, :index))

      assert html =~ "Artwork updated successfully"
      assert html =~ "some updated name"
    end

    test "deletes artwork in listing", %{conn: conn, artwork: artwork} do
      {:ok, index_live, _html} = live(conn, Routes.artwork_index_path(conn, :index))

      assert index_live |> element("#artwork-#{artwork.id} a", "delete") |> render_click()
      refute has_element?(index_live, "#artwork-#{artwork.id}")
    end
  end

  describe "Show" do
    setup [:create_artwork]

    test "displays artwork", %{conn: conn, artwork: artwork} do
      {:ok, _show_live, html} = live(conn, Routes.artwork_show_path(conn, :show, artwork))

      assert html =~ "Show artwork"
      assert html =~ artwork.name
    end

    test "updates artwork within modal", %{conn: conn, artwork: artwork} do
      {:ok, show_live, _html} = live(conn, Routes.artwork_show_path(conn, :show, artwork))

      assert show_live |> element("a", "create") |> render_click() =~
               "Edit Artwork"

      assert_patch(show_live, Routes.artwork_show_path(conn, :edit, artwork))

      assert show_live
             |> form("#artwork-form", artwork: @invalid_attrs)
             |> render_change() =~ "can&#39;t be blank"

      {:ok, _, html} =
        show_live
        |> form("#artwork-form", artwork: @update_attrs)
        |> render_submit()
        |> follow_redirect(conn, Routes.artwork_show_path(conn, :show, artwork))

      assert html =~ "Artwork updated successfully"
      assert html =~ "some updated name"
    end
  end
end
