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
    envs = Application.get_all_env(:jarvis)
    IO.inspect(envs)
  end
end
