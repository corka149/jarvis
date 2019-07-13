defmodule JarvisWeb.MeasurementControllerTest do
  use JarvisWeb.ConnCase

  alias Jarvis.Sensors
  alias Jarvis.Sensors.Measurement
  alias Jarvis.Repo

  @create_attrs %{
    description: "some description",
    value: 120.5
  }
  @update_attrs %{
    description: "some updated description",
    value: 456.7
  }
  @invalid_attrs %{description: nil, value: nil}

  @device_attrs %{location: "some updated location", name: "some updated name", external_id: "f8379a95-2287-41d6-a925-52fa4b0b5cc3"}

  def fixture(:measurement) do
    {:ok, device} = Sensors.create_device(@device_attrs)
    {:ok, measurement} = Sensors.create_measurement(@create_attrs, device)
    measurement
    |> Repo.preload(:device)
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
      {:ok, device} = Sensors.create_device(@device_attrs)
      create_attrs = Map.put(@create_attrs, :device_id, device.id)
      conn = post(conn, Routes.measurement_path(conn, :create), measurement: create_attrs)
      assert %{"id" => id} = json_response(conn, 201)["data"]

      conn = get(conn, Routes.measurement_path(conn, :show, id))

      assert %{
               "id" => id,
               "description" => "some description",
               "value" => 120.5
             } = json_response(conn, 200)["data"]
    end

    test "renders errors when data is invalid", %{conn: conn} do
      {:ok, device} = Sensors.create_device(@device_attrs)
      invalid_attrs = Map.put(@invalid_attrs, :device_id, device.id)
      conn = post(conn, Routes.measurement_path(conn, :create), measurement: invalid_attrs)
      assert json_response(conn, 422)["errors"] != %{}
    end
  end

  describe "update measurement" do
    setup [:create_measurement]

    test "renders measurement when data is valid with old device", %{conn: conn, measurement: %Measurement{id: id} = measurement} do
      conn = put(conn, Routes.measurement_path(conn, :update, measurement), measurement: @update_attrs)
      assert %{"id" => ^id} = json_response(conn, 200)["data"]

      conn = get(conn, Routes.measurement_path(conn, :show, id))
      assert %{
               "id" => id,
               "description" => "some updated description",
               "value" => 456.7,
             } = json_response(conn, 200)["data"]
    end

    test "renders measurement when data is valid with new device", %{conn: conn, measurement: %Measurement{id: id} = measurement} do
      {:ok, device} = Sensors.create_device(@device_attrs)
      update_attrs = Map.put(@update_attrs, :device_id, device.id)
      conn = put(conn, Routes.measurement_path(conn, :update, measurement), measurement: update_attrs)
      assert %{"id" => ^id} = json_response(conn, 200)["data"]

      conn = get(conn, Routes.measurement_path(conn, :show, id))
      device = %{"id" => device.id, "location" => device.location, "name" => device.name}
      assert %{
               "id" => id,
               "description" => "some updated description",
               "value" => 456.7,
               "device" => ^device
             } = json_response(conn, 200)["data"]
    end

    test "renders errors when data is invalid", %{conn: conn, measurement: measurement} do
      conn = put(conn, Routes.measurement_path(conn, :update, measurement), measurement: @invalid_attrs)
      assert json_response(conn, 400)["error"] != %{}
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
