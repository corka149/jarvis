defmodule JarvisWeb.IsleLiveTest do
  use JarvisWeb.ConnCase

  import Phoenix.LiveViewTest
  import Jarvis.TestHelper

  alias Jarvis.AnimalXing

  @create_attrs %{name: "some name", belongs_to: nil}
  @update_attrs %{name: "some updated name", belongs_to: nil}
  @invalid_attrs %{name: nil, belongs_to: nil}

  defp fixture(:isle) do
    user_group = gen_test_data(:user_group)

    {:ok, isle} = AnimalXing.create_isle(@create_attrs, user_group)
    isle
  end

  defp fixture(:user_group) do
    gen_test_data(:user_group)
  end

  defp create_isle(_) do
    isle = fixture(:isle)
    %{isle: isle}
  end

  defp create_group(_) do
    group = fixture(:user_group)
    %{user_group: group}
  end

  setup %{conn: conn} do
    user = gen_test_data(:user)

    conn =
      conn
      |> Phoenix.ConnTest.init_test_session(user_id: user.id)

    {:ok, conn: conn}
  end

  describe "Index" do
    setup [:create_isle, :create_group]

    test "lists all isles", %{conn: conn, isle: isle} do
      {:ok, _index_live, html} = live(conn, Routes.isle_index_path(conn, :index))

      assert html =~ "Listing Isles"
      assert html =~ isle.name
    end

    test "saves new isle", %{conn: conn, user_group: group} do
      conn =
        conn
        |> Phoenix.ConnTest.init_test_session(user_id: group.user.id)

      {:ok, index_live, _html} = live(conn, Routes.isle_index_path(conn, :index))

      assert index_live |> element("a", "add") |> render_click() =~
               "New Isle"

      assert_patch(index_live, Routes.isle_index_path(conn, :new))

      assert index_live
             |> form("#isle-form", isle: %{@invalid_attrs | belongs_to: group.id})
             |> render_change() =~ "can&#39;t be blank"

      {:ok, _, html} =
        index_live
        |> form("#isle-form", isle: %{@create_attrs | belongs_to: group.id})
        |> render_submit()
        |> follow_redirect(conn, Routes.isle_index_path(conn, :index))

      assert html =~ "Isle created successfully"
      assert html =~ "some name"
    end

    test "updates isle in listing", %{conn: conn, isle: isle} do
      {:ok, index_live, _html} = live(conn, Routes.isle_index_path(conn, :index))

      assert index_live |> element("#isle-#{isle.id} a", "create") |> render_click() =~
               "Edit Isle"

      assert_patch(index_live, Routes.isle_index_path(conn, :edit, isle))

      assert index_live
             |> form("#isle-form", isle: @invalid_attrs)
             |> render_change() =~ "can&#39;t be blank"

      {:ok, _, html} =
        index_live
        |> form("#isle-form", isle: @update_attrs)
        |> render_submit()
        |> follow_redirect(conn, Routes.isle_index_path(conn, :index))

      assert html =~ "Isle updated successfully"
      assert html =~ "some updated name"
    end

    test "deletes isle in listing", %{conn: conn, isle: isle} do
      {:ok, index_live, _html} = live(conn, Routes.isle_index_path(conn, :index))

      assert index_live |> element("#isle-#{isle.id} a", "delete") |> render_click()
      refute has_element?(index_live, "#isle-#{isle.id}")
    end
  end

  describe "Show" do
    setup [:create_isle]

    test "displays isle", %{conn: conn, isle: isle} do
      {:ok, _show_live, html} = live(conn, Routes.isle_show_path(conn, :show, isle))

      assert html =~ "Show Isle"
      assert html =~ isle.name
    end

    test "updates isle within modal", %{conn: conn, isle: isle} do
      {:ok, show_live, _html} = live(conn, Routes.isle_show_path(conn, :show, isle))

      assert show_live |> element("a", "create") |> render_click() =~
               "Edit Isle"

      assert_patch(show_live, Routes.isle_show_path(conn, :edit, isle))

      assert show_live
             |> form("#isle-form", isle: @invalid_attrs)
             |> render_change() =~ "can&#39;t be blank"

      {:ok, _, html} =
        show_live
        |> form("#isle-form", isle: @update_attrs)
        |> render_submit()
        |> follow_redirect(conn, Routes.isle_show_path(conn, :show, isle))

      assert html =~ "Isle updated successfully"
      assert html =~ "some updated name"
    end
  end
end
