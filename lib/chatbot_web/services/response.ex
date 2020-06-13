defmodule Response do
  defstruct text: "", quick_replies: []
  def text_message(message) do
    %Response{text: message}
  end
  def text_message(message, quick_replies) do
    %Response{text: message, quick_replies: quick_replies}
  end

  def generic_template(image_url, title, subtitle, buttons) do
    %{
      attachment: %{
        type: "template",
        payload: %{
          template_type: "generic",
          elements: [
            %{
              title: title |> to_string(),
              subtitle: subtitle |> to_string(),
              image_url: image_url |> to_string(),
              buttons: buttons
            }
          ]
        }
      }
    }
  end
end
