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

  defmodule MessengerProfileApi do
    def set_get_started() do
      set_profile(%{
        get_started: %{
          payload: "GET_STARTED"
        }
      })
    end

    def set_profile(payload) do
      jsonBody = Poison.encode!(payload)
      headers = [{"Content-type", "application/json"}]
      "/me/messenger_profile"
      |>  GraphClient.post!(jsonBody, headers)
    end
  end
end
