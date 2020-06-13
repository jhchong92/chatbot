defmodule Goodreads do
  use HTTPoison.Base

  def process_request_url(url) do
    "https://www.goodreads.com" <> url
  end

  def process_request_options(options) do
    param = options[:params] || %{}
    Keyword.merge(options, params: Map.merge(param, %{key: "IREJCaJWttcwlrJSqeco4g"}))
  end

  defmodule Api do
    import SweetXml
    def top_five_books(query) do
      get_books(query)
      |> Enum.take(5)
    end

    def get_books(query) do
      IO.puts "get_books"
      encoded = URI.encode(query)
      Goodreads.get!("/search/index.xml?q=#{encoded}")
      |> (fn(x) -> x.body end).()
      |>  xpath(
          ~x"//search/results/work/best_book"l,
          book_id: ~x"./id/text()",
          book_title: ~x"./title/text()",
          author_name: ~x"./author/name/text()",
          book_image_url: ~x"./image_url/text()"
        )

    end
  end
end
