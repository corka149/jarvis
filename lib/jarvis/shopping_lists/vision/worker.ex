defmodule Jarvis.ShoppingLists.Vision.Worker do
  @moduledoc """
  Offers a Vision syncing API.
  """
  alias Jarvis.ShoppingLists.Vision.Client
  alias Jarvis.ShoppingLists.Vision.Config

  require Logger

  @doc """
  Starts the syncing process with Vision.
  """
  def start_link do
    Task.start_link(fn -> loop_post() end)
  end

  def child_spec(_opts) do
    %{
      id: __MODULE__,
      start: {__MODULE__, :start_link, []},
      type: :worker,
      restart: :permanent,
      shutdown: 500
    }
  end

  @doc """
  Post open lists in a loop to Vision. It takes the deley between post in minutes. THis is archive through Process.sleep/1!

  ## Examples

      iex> get_measurement!(123)
      %Measurement{}

  """
  def loop_post(delay \\ 60, config \\ %Config{}) do
    Logger.info("Run Vision syncing.")
    Task.start_link(fn -> Client.post_open_lists(config) end)
    Process.sleep(delay * 60 * 1000)
    loop_post(delay, config)
  end
end
