defmodule IbmClient do
  use HTTPoison.Base

  def process_request_url(url) do
    base_url = Application.get_env(:chatbot, __MODULE__)[:url]
    base_url <> url
  end

  def process_request_options(options) do
    version = Application.get_env(:chatbot, __MODULE__)[:version]
    basic_auth = [hackney: [basic_auth: {"apikey", Application.get_env(:chatbot, __MODULE__)[:api_key]}]]
    options
    |> Keyword.merge(params: %{version: version})
    |> Keyword.merge(basic_auth)
  end

  def process_request_headers(headers) do
    [{"Content-Type", "application/json"} | headers ]
  end

  defmodule Api do
    def analyze(url) do
      IO.puts "Analyze"

      body = %{
        url: url |> to_string(),
        features: %{
          sentiment: %{}
        }
      }
      encoded = Poison.encode!(body)
      x = IbmClient.post!("/analyze", encoded, [], [])
          |> (fn(x) -> x.body end).()
          |> Poison.decode!()
      IO.inspect x
    end

    def get_sentiment(url) do
      analyze(url)
      |> Map.take(["sentiment"])
    end
  end
end
