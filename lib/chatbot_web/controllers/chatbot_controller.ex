defmodule ChatbotWeb.ChatbotController do
  use ChatbotWeb, :controller
  import SweetXml
  def hello(conn, _params) do
    render(conn, "hello.json")
  end

  def listBooks(conn, _params) do
    HTTPoison.start()
    x = Goodreads.get!("/search/index.xml?q=mockingbird")
    # {doc, []} = x.body |> :binary.bin_to_list() |> :xmerl_scan.string()
    # :xmerl_xpath.string('/GoodreadsResponse/Response', term)
    result = x.body |> xpath(~x"/GoodreadsResponse/search/results/work/best_book/title/text()"l)
    IO.inspect(result)
    render(conn, "hello.json")
  end
end
