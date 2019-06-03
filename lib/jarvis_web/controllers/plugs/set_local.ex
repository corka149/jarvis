defmodule JarvisWeb.Plugs.SetLocale do

  @accept_lang "accept-language"

  def init(params) do
    params
  end

  def call(%{req_headers: req_headers} = conn, default: default) do
    header = Enum.find(req_headers, default, &is_accept_lang_header?/1)

    client_lang = case header do
      {_, client_lang}  -> client_lang
      client_lang       -> client_lang
    end

    Gettext.put_locale client_lang
    conn
  end

  defp is_accept_lang_header?({name, _}) do
    @accept_lang == name
  end
end
