defmodule JarvisWeb.MeasurementControllerTest do
  use JarvisWeb.ConnCase

  alias Jarvis.Sensors
  alias Jarvis.Sensors.Measurement

  @create_attrs %{
    describition: "some describition",
    value: 120.5
  }
  @update_attrs %{
    describition: "some updated describition",
    value: 456.7
  }
  @invalid_attrs %{describition: nil, value: nil}

  def fixture(:measurement) do
    {:ok, measurement} = Sensors.create_measurement(@create_attrs)
    measurement
  end

  setup %{conn: conn} do
    {:ok, conn: put_req_header(conn, "accept", "application/json")}
  end

  describe "index" do
    test "lists all measurements", %{conn: conn} do
      conn = get(conn, Routes.measurement_path(conn, :index))
      assert json_response(conn, 200)["data"] == []
    end
  end

  describe "create measurement" do
    test "renders measurement when data is valid", %{conn: conn} do
      conn = post(conn, Routes.measurement_path(conn, :create), measurement: @create_attrs)
      assert %{"id" => id} = json_response(conn, 201)["data"]

      conn = get(conn, Routes.measurement_path(conn, :show, id))

      assert %{
               "id" => id,
               "describition" => "some describition",
               "value" => 120.5
             } = json_response(conn, 200)["data"]
    end

    test "renders errors when data is invalid", %{conn: conn} do
      conn = post(conn, Routes.measurement_path(conn, :create), measurement: @invalid_attrs)
      assert json_response(conn, 422)["errors"] != %{}
    end
  end

  describe "update measurement" do
    setup [:create_measurement]

    test "renders measurement when data is valid", %{conn: conn, measurement: %Measurement{id: id} = measurement} do
      conn = put(conn, Routes.measurement_path(conn, :update, measurement), measurement: @update_attrs)
      assert %{"id" => ^id} = json_response(conn, 200)["data"]

      conn = get(conn, Routes.measurement_path(conn, :show, id))

      assert %{
               "id" => id,
               "describition" => "some updated describition",
               "value" => 456.7
             } = json_response(conn, 200)["data"]
    end

    test "renders errors when data is invalid", %{conn: conn, measurement: measurement} do
      conn = put(conn, Routes.measurement_path(conn, :update, measurement), measurement: @invalid_attrs)
      assert json_response(conn, 422)["errors"] != %{}
    end
  end

  describe "delete measurement" do
    setup [:create_measurement]

    test "deletes chosen measurement", %{conn: conn, measurement: measurement} do
      conn = delete(conn, Routes.measurement_path(conn, :delete, measurement))
      assert response(conn, 204)

      assert_error_sent 404, fn ->
        get(conn, Routes.measurement_path(conn, :show, measurement))
      end
    end
  end

  defp create_measurement(_) do
    measurement = fixture(:measurement)
    {:ok, measurement: measurement}
  end
end
