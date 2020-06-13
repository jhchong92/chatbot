defmodule ChatbotWeb.ChatbotController do
  use ChatbotWeb, :controller
  def hello(conn, _params) do
    IO.inspect(Application.get_all_env(:chatbot))
    render(conn, "hello.json")
  end

  def listBooks(conn, _params) do
    HTTPoison.start()
    books = Goodreads.Api.top_five_books("mockingbird")
    IO.inspect(books)
    book = List.first(books)
    template = AttachmentTemplateFactory.book_attachment(book)
    |> AttachmentTemplate.getAttachment()
    IO.inspect template
    user = %{id: "2883908308404075", first_name: "Chong", last_name: "Hao"}
    # encoded = Poison.encode!( %{
    #   recipient: %{
    #     id: user.id
    #   },
    #   message: template
    # })

    # IO.inspect encoded
    x = GraphClient.Api.send_template(user, template)
    IO.inspect x
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
        [responses] = Enum.map(entry, fn(x) -> handleEntry(x) end)
        IO.puts("!!!!!Response!!!!!")
        IO.inspect(responses)
        responses
        |> Enum.each((fn(response) -> GraphClient.Api.send_message(user, response) end))
        # Enum.each(responses, fun)

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
    quick_reply = Map.get(message, "quick_reply")
    text = Map.get(message, "text")
    cond do
      postback ->
        handlePostback(postback)
      quick_reply ->
        handleQuickReply(quick_reply)
      text ->
        handleTextMessage(text)
    end
  end

  defp handlePostback(postback) do
    IO.puts("handlePostback")
    payload = Map.get(postback, "payload")
    handlePayload(payload)
  end

  defp handleTextMessage(text) do
    IO.puts("handleTextMessage")
    cond do
      Integer.parse(text) ->
        # search goodread books
        IO.puts("Search by ID")
      true ->
        # search by title
        IO.puts("Search by title")

    end


    [ResponseFactory.fallback()]
  end

  defp handleQuickReply(quick_reply) do
    IO.puts("handleQuickReply")
    payload = Map.get(quick_reply, "payload")
    handlePayload(payload)
  end

  defp handlePayload(payload) do
    cond do
      payload == "GET_STARTED" ->
        [ResponseFactory.get_started()]
      payload == "SEARCH_BOOK_TITLE" ->
        [ResponseFactory.request_book_title()]
      payload == "SEARCH_GOODREADS_ID" ->
        [ResponseFactory.request_goodreads_id()]
      payload |> String.contains?("BOOK_REVIEW_") ->
        book_id = payload
        |> String.slice(String.length("BOOK_REVIEW_")..-1)

      true ->
        nil
    end
  end
end
