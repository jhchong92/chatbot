defmodule Response do
  defstruct text: "", quick_replies: []
  def text_message(message) do
    %Response{text: message}
  end
  def text_message(message, quick_replies) do
    %Response{text: message, quick_replies: quick_replies}
  end
end
