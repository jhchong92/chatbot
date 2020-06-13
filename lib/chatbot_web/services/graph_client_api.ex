defmodule GraphClient.Api do

  def get_profile(id) do

  "/" <> id
  |>  GraphClient.get!([], params: %{fields: "first_name, last_name"})
  |> (fn(x) -> x.body end).()
  |> Poison.decode(keys: :atoms)
  |> case  do
    {:ok, parsed} -> parsed

    end
  end


  def send_message(user, message, quick_replies) do
    headers = [{"Content-type", "application/json"}]

    body = Poison.encode!( %{
      recipient: %{
        id: user.id
      },
      message: %{
        text: message,
        quick_replies: quick_replies
      }
    })
    "/me/messages"
    |>  GraphClient.post!(body, headers)
  end

  def send_message(user, response) do
    send_message(user, response.text, response.quick_replies)
  end
end
