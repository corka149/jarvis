defmodule JarvisWeb.DeviceControllerTest do
  use JarvisWeb.ConnCase

  alias Jarvis.Sensors
  alias Jarvis.Sensors.Device

  @create_attrs %{
    location: "some location",
    name: "some name",
    external_id: "f8379a95-2287-41d6-a925-52fa4b0b5cc3"
  }
  @update_attrs %{
    location: "some updated location",
    name: "some updated name",
    external_id: "f8379a95-2287-41d6-a925-52fa4b0b5cc3"
  }
  @invalid_attrs %{location: nil, name: nil, external_id: nil}

  def fixture(:device) do
    {:ok, device} = Sensors.create_device(@create_attrs)
    device
  end

  setup %{conn: conn} do
    {:ok, conn: put_req_header(conn, "accept", "application/json")}
  end

  describe "index" do
    test "lists all devices", %{conn: conn} do
      conn = get(conn, Routes.device_path(conn, :index))
      assert json_response(conn, 200)["data"] == []
    end
  end

  describe "create device" do
    test "renders device when data is valid", %{conn: conn} do
      conn = post(conn, Routes.device_path(conn, :create), device: @create_attrs)
      assert %{"id" => id} = json_response(conn, 201)["data"]

      conn = get(conn, Routes.device_path(conn, :show, id))

      assert %{
               "id" => id,
               "location" => "some location",
               "name" => "some name"
             } = json_response(conn, 200)["data"]
    end

    test "renders errors when data is invalid", %{conn: conn} do
      conn = post(conn, Routes.device_path(conn, :create), device: @invalid_attrs)
      assert json_response(conn, 422)["errors"] != %{}
    end
  end

  describe "update device" do
    setup [:create_device]

    test "renders device when data is valid", %{conn: conn, device: %Device{id: id} = device} do
      conn = put(conn, Routes.device_path(conn, :update, device), device: @update_attrs)
      assert %{"id" => ^id} = json_response(conn, 200)["data"]

      conn = get(conn, Routes.device_path(conn, :show, id))

      assert %{
               "id" => id,
               "location" => "some updated location",
               "name" => "some updated name"
             } = json_response(conn, 200)["data"]
    end

    test "renders errors when data is invalid", %{conn: conn, device: device} do
      conn = put(conn, Routes.device_path(conn, :update, device), device: @invalid_attrs)
      assert json_response(conn, 422)["errors"] != %{}
    end
  end

  describe "delete device" do
    setup [:create_device]

    test "deletes chosen device", %{conn: conn, device: device} do
      conn = delete(conn, Routes.device_path(conn, :delete, device))
      assert response(conn, 204)

      assert_error_sent 404, fn ->
        get(conn, Routes.device_path(conn, :show, device))
      end
    end
  end

  describe "getting device" do
    setup [:create_device]

    test "get device by existing external id", %{conn: conn, device: device}  do
      url = Routes.device_path(conn, :get_by_external_id, device.external_id)
      conn = get(conn, url)

      assert %{
        "id" => id,
        "location" => "some location",
        "name" => "some name"
      } = json_response(conn, 200)["data"]
    end

    test "get device by not existing external id", %{conn: conn}  do
      url = Routes.device_path(conn, :get_by_external_id, Ecto.UUID.generate())

      response = get(conn, url)
      assert 404 == response.status
    end
  end

  defp create_device(_) do
    device = fixture(:device)
    {:ok, device: device}
  end
end
