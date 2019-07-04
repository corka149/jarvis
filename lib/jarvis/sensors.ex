defmodule Jarvis.Sensors do
  @moduledoc """
  The Sensors context.
  """

  import Ecto.Query, warn: false
  alias Jarvis.Repo

  alias Jarvis.Sensors.Measurement
  alias Jarvis.Sensors.Device

  @doc """
  Returns the list of measurements.

  ## Examples

      iex> list_measurements()
      [%Measurement{}, ...]

  """
  def list_measurements do
    Repo.all(Measurement)
    |> Repo.preload(:device)
  end

  @doc """
  Loads all measurements that belong to a certain device.
  """
  def list_measurements_by_device(%Device{} = device) do
    from(measurements in Measurement, where: measurements.device_id == ^device.id)
    |> Repo.all()
    |> Repo.preload(:device)
  end

  @doc """
  Gets a single measurement.

  Raises `Ecto.NoResultsError` if the Measurement does not exist.

  ## Examples

      iex> get_measurement!(123)
      %Measurement{}

      iex> get_measurement!(456)
      ** (Ecto.NoResultsError)

  """
  def get_measurement!(id), do: Repo.get!(Measurement, id) |> Repo.preload(:device)

  @doc """
  Creates a measurement.

  ## Examples

      iex> create_measurement(%{field: value}, %Device{})
      {:ok, %Measurement{}}

      iex> create_measurement(%{field: bad_value}, %Device{})
      {:error, %Ecto.Changeset{}}

  """
  def create_measurement(attrs \\ %{}, %Device{} = device) do
    Ecto.build_assoc(device, :measurements)
    |> Measurement.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a measurement.

  ## Examples

      iex> update_measurement(measurement, %{field: new_value}, %Device{})
      {:ok, %Measurement{}}

      iex> update_measurement(measurement, %{field: bad_value}, %Device{})
      {:error, %Ecto.Changeset{}}

  """
  def update_measurement(%Measurement{} = measurement, attrs, %Device{} = device) do
    change_set = Repo.get!(Measurement, measurement.id) |> Measurement.changeset(attrs)

    device
    |> Ecto.Changeset.change()
    |> Ecto.Changeset.put_assoc(:measurements, [change_set])
    |> Jarvis.Repo.update()
  end


  def update_measurement(%Measurement{} = measurement, attrs) do
    measurement
    |> Measurement.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a Measurement.

  ## Examples

      iex> delete_measurement(measurement)
      {:ok, %Measurement{}}

      iex> delete_measurement(measurement)
      {:error, %Ecto.Changeset{}}

  """
  def delete_measurement(%Measurement{} = measurement) do
    Repo.delete(measurement)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking measurement changes.

  ## Examples

      iex> change_measurement(measurement)
      %Ecto.Changeset{source: %Measurement{}}

  """
  def change_measurement(%Measurement{} = measurement) do
    Measurement.changeset(measurement, %{})
  end

  @doc """
  Returns the list of devices.

  ## Examples

      iex> list_devices()
      [%Device{}, ...]

  """
  def list_devices do
    Repo.all(Device)
    |> Repo.preload(:measurements)
  end

  @doc """
  Gets a single device.

  Raises `Ecto.NoResultsError` if the Device does not exist.

  ## Examples

      iex> get_device!(123)
      %Device{}

      iex> get_device!(456)
      ** (Ecto.NoResultsError)

  """
  def get_device!(id), do: Repo.get!(Device, id) |> Repo.preload(:measurements)

  @doc """
  Creates a device.

  ## Examples

      iex> create_device(%{field: value})
      {:ok, %Device{}}

      iex> create_device(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_device(attrs \\ %{}) do
    %Device{}
    |> Device.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a device.

  ## Examples

      iex> update_device(device, %{field: new_value})
      {:ok, %Device{}}

      iex> update_device(device, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_device(%Device{} = device, attrs) do
    device
    |> Device.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a Device.

  ## Examples

      iex> delete_device(device)
      {:ok, %Device{}}

      iex> delete_device(device)
      {:error, %Ecto.Changeset{}}

  """
  def delete_device(%Device{} = device) do
    Repo.delete(device)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking device changes.

  ## Examples

      iex> change_device(device)
      %Ecto.Changeset{source: %Device{}}

  """
  def change_device(%Device{} = device) do
    Device.changeset(device, %{})
  end
end
