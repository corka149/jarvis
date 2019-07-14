defmodule Jarvis.SensorsTest do
  use Jarvis.DataCase

  alias Jarvis.Sensors
  alias Jarvis.Repo

  describe "measurements" do
    alias Jarvis.Sensors.Measurement

    @valid_attrs %{description: "some description", value: 120.5}
    @update_attrs %{description: "some updated description", value: 456.7}
    @invalid_attrs %{description: nil, value: nil}

    def measurement_fixture(attrs \\ %{}) do
      {:ok, device} = Sensors.create_device(%{location: "some updated location", name: "some updated name", external_id: "f8379a95-2287-41d6-a925-52fa4b0b5cc3"})

      {:ok, measurement} =
        attrs
        |> Enum.into(@valid_attrs)
        |> Sensors.create_measurement(device)

      measurement
      |> Repo.preload(:device)
    end

    test "list_measurements/0 returns all measurements" do
      measurement = measurement_fixture()
      assert Sensors.list_measurements() == [measurement]
    end

    test "get_measurement!/1 returns the measurement with given id" do
      measurement = measurement_fixture()
      assert Sensors.get_measurement!(measurement.id) == measurement
    end

    test "create_measurement/1 with valid data creates a measurement" do
      {:ok, device} = Sensors.create_device(%{location: "some updated location", name: "some updated name", external_id: "f8379a95-2287-41d6-a925-52fa4b0b5cc3"})

      assert {:ok, %Measurement{} = measurement} = Sensors.create_measurement(@valid_attrs, device)
      assert measurement.description == "some description"
      assert measurement.value == 120.5
    end

    test "create_measurement/1 with invalid data returns error changeset" do
      {:ok, device} = Sensors.create_device(%{location: "some updated location", name: "some updated name", external_id: "f8379a95-2287-41d6-a925-52fa4b0b5cc3"})

      assert {:error, %Ecto.Changeset{}} = Sensors.create_measurement(@invalid_attrs, device)
    end

    test "update_measurement/2 with valid data updates the measurement" do
      measurement = measurement_fixture()
      assert {:ok, %Measurement{} = measurement} = Sensors.update_measurement(measurement, @update_attrs)
      assert measurement.description == "some updated description"
      assert measurement.value == 456.7
    end

    test "update_measurement/2 with invalid data returns error changeset" do
      measurement = measurement_fixture()
      assert {:error, %Ecto.Changeset{}} = Sensors.update_measurement(measurement, @invalid_attrs)
      assert measurement == Sensors.get_measurement!(measurement.id)
    end

    test "delete_measurement/1 deletes the measurement" do
      measurement = measurement_fixture()
      assert {:ok, %Measurement{}} = Sensors.delete_measurement(measurement)
      assert_raise Ecto.NoResultsError, fn -> Sensors.get_measurement!(measurement.id) end
    end

    test "change_measurement/1 returns a measurement changeset" do
      measurement = measurement_fixture()
      assert %Ecto.Changeset{} = Sensors.change_measurement(measurement)
    end
  end

  describe "devices" do
    alias Jarvis.Sensors.Device

    @valid_attrs %{location: "some location", name: "some name", external_id: "f8379a95-2287-41d6-a925-52fa4b0b5cc3"}
    @update_attrs %{location: "some updated location", name: "some updated name", external_id: "f8379a95-2287-41d6-a925-52fa4b0b5cc3"}
    @invalid_attrs %{location: nil, name: nil, external_id: nil}

    def device_fixture(attrs \\ %{}) do
      {:ok, device} =
        attrs
        |> Enum.into(@valid_attrs)
        |> Sensors.create_device()

      device
      |> Repo.preload(:measurements)
    end

    test "list_devices/0 returns all devices" do
      device = device_fixture()
      assert Sensors.list_devices() == [device]
    end

    test "get_device!/1 returns the device with given id" do
      device = device_fixture()
      assert Sensors.get_device!(device.id) == device
    end

    test "create_device/1 with valid data creates a device" do
      assert {:ok, %Device{} = device} = Sensors.create_device(@valid_attrs)
      assert device.location == "some location"
      assert device.name == "some name"
    end

    test "create_device/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Sensors.create_device(@invalid_attrs)
    end

    test "update_device/2 with valid data updates the device" do
      device = device_fixture()
      assert {:ok, %Device{} = device} = Sensors.update_device(device, @update_attrs)
      assert device.location == "some updated location"
      assert device.name == "some updated name"
    end

    test "update_device/2 with invalid data returns error changeset" do
      device = device_fixture()
      assert {:error, %Ecto.Changeset{}} = Sensors.update_device(device, @invalid_attrs)
      assert device == Sensors.get_device!(device.id)
    end

    test "delete_device/1 deletes the device" do
      device = device_fixture()
      assert {:ok, %Device{}} = Sensors.delete_device(device)
      assert_raise Ecto.NoResultsError, fn -> Sensors.get_device!(device.id) end
    end

    test "change_device/1 returns a device changeset" do
      device = device_fixture()
      assert %Ecto.Changeset{} = Sensors.change_device(device)
    end

    test "get_device_by_external_id when external id exists" do
      device = device_fixture()
      external_id = device.external_id
      assert %Device{} = Sensors.get_device_by_external_id(external_id)
    end

    test "get_device_by_external_id when external id does not exist" do
      device = device_fixture()
      external_id = Ecto.UUID.generate()
      assert nil == Sensors.get_device_by_external_id(external_id)
    end
  end
end
