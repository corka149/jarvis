defmodule JarvisWeb.Api.SystemControllerTest do
  use JarvisWeb.ConnCase

  setup %{conn: conn} do
    {:ok, conn: put_req_header(conn, "accept", "application/json")}
  end

  test "request readiness", %{conn: conn} do
    conn = get(conn, Routes.system_path(conn, :ready))
    assert response(conn, 200)
    assert text_response(conn, 200) =~ "jARVIS is ready"
  end

end
