defmodule JarvisWeb.ListLiveTest do
  use JarvisWeb.ConnCase

  import Phoenix.LiveViewTest
  import Jarvis.ShoppingFixtures

  @create_attrs %{status: :open, title: "some title", purchase_at: "2026-02-07"}
  @update_attrs %{status: :done, title: "some updated title", purchase_at: "2026-02-08"}
  @invalid_attrs %{status: nil, title: nil, purchase_at: nil}
  defp create_list(_) do
    list = list_fixture()

    %{list: list}
  end

  describe "Index" do
    setup [:create_list]

    test "lists all shopping_lists", %{conn: conn, list: list} do
      {:ok, _index_live, html} = live(conn, ~p"/shopping_lists")

      assert html =~ "Listing Shopping lists"
      assert html =~ list.title
    end

    test "saves new list", %{conn: conn} do
      {:ok, index_live, _html} = live(conn, ~p"/shopping_lists")

      assert {:ok, form_live, _} =
               index_live
               |> element("a", "New List")
               |> render_click()
               |> follow_redirect(conn, ~p"/shopping_lists/new")

      assert render(form_live) =~ "New List"

      assert form_live
             |> form("#list-form", list: @invalid_attrs)
             |> render_change() =~ "can&#39;t be blank"

      assert {:ok, index_live, _html} =
               form_live
               |> form("#list-form", list: @create_attrs)
               |> render_submit()
               |> follow_redirect(conn, ~p"/shopping_lists")

      html = render(index_live)
      assert html =~ "List created successfully"
      assert html =~ "some title"
    end

    test "updates list in listing", %{conn: conn, list: list} do
      {:ok, index_live, _html} = live(conn, ~p"/shopping_lists")

      assert {:ok, form_live, _html} =
               index_live
               |> element("#shopping_lists-#{list.id} a", "Edit")
               |> render_click()
               |> follow_redirect(conn, ~p"/shopping_lists/#{list}/edit")

      assert render(form_live) =~ "Edit List"

      assert form_live
             |> form("#list-form", list: @invalid_attrs)
             |> render_change() =~ "can&#39;t be blank"

      assert {:ok, index_live, _html} =
               form_live
               |> form("#list-form", list: @update_attrs)
               |> render_submit()
               |> follow_redirect(conn, ~p"/shopping_lists")

      html = render(index_live)
      assert html =~ "List updated successfully"
      assert html =~ "some updated title"
    end

    test "deletes list in listing", %{conn: conn, list: list} do
      {:ok, index_live, _html} = live(conn, ~p"/shopping_lists")

      assert index_live |> element("#shopping_lists-#{list.id} a", "Delete") |> render_click()
      refute has_element?(index_live, "#shopping_lists-#{list.id}")
    end
  end

  describe "Show" do
    setup [:create_list]

    test "displays list", %{conn: conn, list: list} do
      {:ok, _show_live, html} = live(conn, ~p"/shopping_lists/#{list}")

      assert html =~ "Show List"
      assert html =~ list.title
    end

    test "updates list and returns to show", %{conn: conn, list: list} do
      {:ok, show_live, _html} = live(conn, ~p"/shopping_lists/#{list}")

      assert {:ok, form_live, _} =
               show_live
               |> element("a", "Edit")
               |> render_click()
               |> follow_redirect(conn, ~p"/shopping_lists/#{list}/edit?return_to=show")

      assert render(form_live) =~ "Edit List"

      assert form_live
             |> form("#list-form", list: @invalid_attrs)
             |> render_change() =~ "can&#39;t be blank"

      assert {:ok, show_live, _html} =
               form_live
               |> form("#list-form", list: @update_attrs)
               |> render_submit()
               |> follow_redirect(conn, ~p"/shopping_lists/#{list}")

      html = render(show_live)
      assert html =~ "List updated successfully"
      assert html =~ "some updated title"
    end
  end
end
