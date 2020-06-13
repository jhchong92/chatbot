defmodule AttachmentButtonFactory do
  def postback(title, payload) do
    %{type: "postback", title: title, payload: payload}
  end

  def review(book) do
    postback("Review", "BOOK_REVIEW_#{book.id}")
  end
end
