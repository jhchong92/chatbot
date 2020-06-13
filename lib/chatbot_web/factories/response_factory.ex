defmodule ResponseFactory do
  def get_started() do
    Response.text_message("""
      Thank you for using Goodreads' service. We can provide search results
      based on a book title or a Goodreads book ID. Which would you prefer?
      """,
      [
        QuickReply.new("Book Title", "SEARCH_BOOK_TITLE"),
        QuickReply.new("Goodreads Book ID", "SEARCH_GOODREADS_ID"),
      ]
    )
  end

  def request_book_title() do
    Response.text_message("Please enter the title that you would like to search")
  end

  def request_goodreads_id() do
    Response.text_message("Please enter a Goodreads book ID that you would like to search. (e.g. 44458285")
  end

  def fallback() do
    Response.text_message("""
      Sorry.. I'm still new. Please navigate the conversation by clicking on the
      available option buttons.
    """, [
      QuickReply.new("Start again", "GET_STARTED")
    ])
  end
end
