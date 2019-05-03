defmodule JarvisWeb.AuthController do
  use JarvisWeb, :controller
  plug Ueberauth

  def callback(conn, params) do
    IO.puts "===================="
    IO.inspect(conn.assigns)
    IO.inspect(params)
    IO.puts "===================="
  end

end
