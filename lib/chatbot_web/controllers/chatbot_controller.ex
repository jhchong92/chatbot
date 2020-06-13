defmodule ChatbotWeb.ChatbotController do
  use ChatbotWeb, :controller
  import SweetXml
  def hello(conn, _params) do
    IO.inspect(Application.get_all_env(:chatbot))
    # IO.inspect(Application.get_env(:chatbot, __MODULE__)[:page_access_token])
    # Map.merge(%{abc: "abc"}, %{bcd: %{efg: "efg"}})
    try do
      conn.x
    rescue
      _ -> "Hello"
    end

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

    object = Map.get(params, "object")
    user = GraphClient.Api.get_profile("2883908308404075")
    if (object === "page") do
      entry = Map.get(params, "entry")
      try do
        [response] = Enum.map(entry, fn(x) -> handleEntry(x) end)
        IO.puts("!!!!!Response!!!!!")
        IO.inspect(response)
        GraphClient.Api.send_message(user, response)
      rescue
        _ -> "Error!"
      end
    end
    # {:ok, body, _conn} = read_body(conn)
    # IO.puts("*******Body*********")
    # IO.inspect(body)


    # user = %{id: "2883908308404075", first_name: "Chong", last_name: "Hao"}
    # x = GraphClient.Api.send_message(user, "Hello you", ["Thanks"])
    # IO.inspect(x)

    conn
      |> put_status(:ok)
      |> text("hello")
  end

  def setup(conn, _params) do
    IO.puts("setup")
    x = GraphClient.MessengerProfileApi.set_get_started()
    IO.inspect(x)
    conn
      |> put_status(:ok)
      |> text("setup")
  end


  defp handleEntry(entry) do
    IO.puts("handleEntry")
    IO.inspect(entry)
    [head] = Map.get(entry, "messaging")
    handleMessage(head)
  end

  defp handleMessage(message) do
    IO.puts("handleMessage")
    IO.inspect(message)
    postback = Map.get(message, "postback")
    quick_replies = Map.get(message, "quick_replies")
    text = Map.get(message, "text")
    cond do
      postback ->
        handlePostback(postback)
      quick_replies ->
        handleQuickReply(quick_replies)
      text ->
        handleTextMessage(message)
    end
  end

  defp handlePostback(postback) do
    IO.puts("handlePostback")
    payload = Map.get(postback, "payload")
    handlePayload(payload)
  end

  defp handleTextMessage(message) do
    IO.puts("handleTextMessage")
  end

  defp handleQuickReply(quick_replies) do
    IO.puts("handleQuickReply")
  end

  defp handlePayload(payload) do
    cond do
      payload == "GET_STARTED" ->
        quickReplies = [
          QuickReply.new("Name", "SEARCH_NAME"),
          QuickReply.new("ID", "SEARCH_ID")
        ]
      Response.text_message("Search by", quickReplies)
      true ->
        nil
    end
  end
end
