defmodule Goodreads do
  use HTTPoison.Base

  def process_request_url(url) do
    "https://www.goodreads.com" <> url
  end

  def process_request_options(options) do
    param = options[:params] || %{}
    Keyword.merge(options, params: Map.merge(param, %{key: "IREJCaJWttcwlrJSqeco4g"}))
  end
end
