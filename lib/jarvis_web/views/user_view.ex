defmodule JarvisWeb.UserView do
  use JarvisWeb, :view

  @doc """
  Defines available languages for selection
  """
  def languages do
    [Deutsch: "de", English: "en"]
  end

  @doc """
  Returns language name by language code
  """
  def language_name(lang_code) do
    {lang, _code} =
      Enum.find(languages(), {:English, "en"}, fn {_lang, code} -> code == lang_code end)

    lang
  end
end
