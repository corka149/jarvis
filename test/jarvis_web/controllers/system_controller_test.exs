defmodule JarvisWeb.SystemControllerTest do
  use Plug.Test
  use JarvisWeb.ConnCase

  # ===== TESTS =====

  test "Check availability of readiness endpoint", %{conn: conn} do
    conn = conn |> get(Routes.system_path(conn, :ready))
    body = json_response(conn, 200)
    assert [%{"jarvis" => "Was started"}] = body
  end
end
