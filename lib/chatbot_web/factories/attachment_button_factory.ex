defmodule AttachmentButtonFactory do
  def postback(title, payload) do
    %{type: "postback", title: title, payload: payload}
  end

  def our_thoughts(book) do
    postback("Our thoughts", "BOOK_REVIEW_#{book.id}")
  end
end
