defmodule Jarvis.Util.ApplicationInfo do
  @moduledoc """
  Provides methods for printing application details.
  """
  require Logger

  def print_banner() do
    banner = ~S"
===== ===== ===== ===== ===== ===== ===== =====
       _  ___     ____  _    __ ____ _____
      (_)/   |   / __ \| |  / //  _// ___/
     / // /| |  / /_/ /| | / / / /  \__ \
    / // ___ | / _, _/ | |/ /_/ /  ___/ /
 __/ //_/  |_|/_/ |_|  |___//___/ /____/
/___/

===== ===== ===== ===== ===== ===== ===== =====
    "
    Logger.info(banner)
  end

  def print_application_env() do
    app_configs = Application.get_all_env(:jarvis)
    do_print_app(app_configs)
    ueberauth = Application.get_all_env(:ueberauth)
    do_print_app(ueberauth)
  end

  defp do_print_app([]), do: :ok

  defp do_print_app([{key, values} | tail]) do
    Logger.info("App: #{key}")
    print_config(values)

    do_print_app(tail)
  end

  defp print_config([]), do: :ok

  defp print_config([{conf, value} | tail])
       when is_binary(value) or is_number(value) or is_boolean(value) or is_atom(value) do
    conf = Atom.to_string(conf)

    if conf =~ "password" or conf =~ "secret" do
      print_secrets(conf, value)
    else
      Logger.info("\t#{conf}: #{value}")
    end

    print_config(tail)
  end

  # Ignore other types
  defp print_config([_ | tail]), do: print_config(tail)

  defp print_secrets(conf, value) do
    len = String.length(value) - 3
    rang = Range.new(0, len)
    replacement = Enum.map_join(rang, fn _ -> "*" end)
    Logger.info("\t#{conf}: #{String.first(value)}#{replacement}#{String.last(value)}")
  end
end
