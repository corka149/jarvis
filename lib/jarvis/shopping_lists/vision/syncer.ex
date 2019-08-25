defmodule Jarvis.ShoppingLists.Vision.Syncer do
  alias Jarvis.ShoppingLists.Vision.Syncer
  alias Jarvis.ShoppingLists.Vision.Client
  alias Jarvis.ShoppingLists.Vision.Config

  def start_syncer() do
    spawn_link(Syncer, :push_loop, [name: __MODULE__])
  end

  def push_loop() do
    Task.start_link(fn -> Config.from_env() |> Client.post_open_lists() end)
    Process.sleep(12 * 60 * 60 * 1000) # Every 1/2 day
    push_loop()
  end
end
