defmodule AttachmentTemplateFactory do

  import AttachmentTemplate
  def new() do
    %AttachmentTemplate{}
  end

  def book_attachment(book) do
    %AttachmentTemplate{}
    |> setTitle(book.title)
    |> setSubtitle(book.author_name)
    |> setImageUrl(book.image_url)
    |> setButtons([
      AttachmentButtonFactory.our_thoughts(book)
    ])
  end
end
