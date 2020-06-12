defmodule GraphClient do
  use HTTPoison.Base

  def process_request_url(url) do
    "https://graph.facebook.com" <> url
  end

  def process_request_options(options) do
    param = options[:params] || %{}
    merged = Map.merge(
      param, %{access_token: Application.get_env(:chatbot, __MODULE__)[:page_access_token]}
    )
    Keyword.merge(options,
      params: merged
    )
  end
end
