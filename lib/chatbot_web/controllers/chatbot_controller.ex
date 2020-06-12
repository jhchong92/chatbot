defmodule ChatbotWeb.ChatbotController do
  use ChatbotWeb, :controller
  import SweetXml
  def hello(conn, _params) do
    IO.inspect(Application.get_all_env(:chatbot))
    # IO.inspect(Application.get_env(:chatbot, __MODULE__)[:page_access_token])
    # Map.merge(%{abc: "abc"}, %{bcd: %{efg: "efg"}})

    # user = GraphClient.Api.get_profile("2883908308404075")
        # |> (fn(x) -> x.body end).()
        # |> Poison.decode(keys: :atoms)
    # IO.inspect(user)
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

  def hook(conn, params) do
    mode = Map.get(params, "hub.mode")
    token = Map.get(params, "hub.verify_token")
    challenge = Map.get(params, "hub.challenge")

    status = if mode == "subscribe" && token == "ba212eeb69a50f8c4e3533992e98a125" do
      :ok
    else
      :forbidden
    end

    IO.inspect(params)
    conn
      |> put_status(status)
      |> text(challenge)
  end

  def hookHandle(conn, params) do
    IO.puts("*******Conn*********")
    IO.inspect(conn)
    IO.puts("*******Params*********")
    IO.inspect(params)

    # {:ok, body, _conn} = read_body(conn)
    # IO.puts("*******Body*********")
    # IO.inspect(body)

    # user = GraphClient.Api.get_profile("2883908308404075")
    user = %{id: "2883908308404075", first_name: "Chong", last_name: "Hao"}
    x = GraphClient.Api.send_message(user, "Hello you", ["Thanks"])
    IO.inspect(x)
    conn
      |> put_status(:ok)
      |> text("hello")
  end


end
