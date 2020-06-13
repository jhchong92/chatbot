defmodule QuickReply do
  defstruct content_type: "text", title: "Title", payload: "payload"

  def new(title, payload) do
    %QuickReply{title: title, payload: payload}
  end

end
