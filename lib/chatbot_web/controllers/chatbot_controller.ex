defmodule ChatbotWeb.ChatbotController do
  use ChatbotWeb, :controller
  def hello(conn, _params) do
    # books = Goodreads.Api.top_five_books("Mockingbird")
    user = %{id: "2883908308404075", first_name: "Chong", last_name: "Hao"}
    response = %{
      attachment: %{
        payload: %{
          elements: [
            %{
              buttons: [
                %{
                  payload: "BOOK_REVIEW_24817626",
                  title: "Review",
                  type: "postback"
                }
              ],
              image_url: "https://i.gr-assets.com/images/S/compressed.photo.goodreads.com/books/1451442088l/24817626._SX98_.jpg",
              subtitle: "Harper Lee",
              title: "Go Set a Watchman (To Kill a Mockingbird)"
            }
          ],
          template_type: "generic"
        },
        type: "template"
      }
    }
    GraphClient.Api.send_template(user, response)

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

    # IO.inspect encoded
    x = GraphClient.Api.send_template(user, template)
    IO.inspect x
    render(conn, "hello.json")
  end

  def hook(conn, params) do
    mode = Map.get(params, "hub.mode")
    token = Map.get(params, "hub.verify_token")
    challenge = Map.get(params, "hub.challenge")

    status = if mode == "subscribe" &&
              token == Application.get_env(:chatbot, __MODULE__)[:verify_token] do
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
        |> Enum.each((fn(response) -> GraphClient.Api.send_response(user, response) end))
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
    handleMessaging(head)
  end

  defp handleMessaging(messaging) do
    IO.puts("handleMessaging")
    IO.inspect(messaging)
    postback = Map.get(messaging, "postback")
    # IO.inspect(postback)
    quick_reply = get_in(messaging, ["message", "quick_reply"])
    text = get_in(messaging, ["message", "text"])
    IO.puts "text"
    IO.inspect(text)
    cond do
      postback ->
        handlePostback(postback)
      quick_reply ->
        handleQuickReply(quick_reply)
      text ->
        handleTextMessage(text)
      true ->
        IO.puts "Unhandled message"
    end
  end

  defp handlePostback(postback) do
    IO.puts("handlePostback")
    payload = Map.get(postback, "payload")
    handlePayload(payload)
  end

  defp handleTextMessage(text) do
    IO.puts("handleTextMessage")
    book_id = Integer.parse(text)
    IO.inspect book_id
    books = cond do
      {:error} ->
        # search by title
        IO.puts("Search by title")
        Goodreads.Api.top_five_books(text)
      true ->
        # search goodread books
        IO.puts("Search by ID")
        book = Goodreads.Api.get_book(book_id)
        if book != nil do
          [book]
        else
          []
        end
    end

    if length(books) > 0 do
      Enum.concat([
        ResponseFactory.general_message("Here's what we found"),
      ], Enum.map(books, fn(book) -> ResponseFactory.suggest_book(book) end))
    else
      [ResponseFactory.book_empty_results()]
    end

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
        x = Goodreads.Api.get_review_iframe_url(book_id)
        IO.puts "Sentiment"
        sentiment = IbmClient.Api.get_sentiment(x) |> IO.inspect
        [ResponseFactory.book_review(sentiment)]
      true ->
        nil
    end
  end
end
