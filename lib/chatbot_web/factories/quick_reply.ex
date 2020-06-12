defmodule QuickReply do
  defstruct content_type: "text", title: "Title", payload: "payload"

  def new(title) do
    %QuickReply{title: title, payload: title}
  end

end
