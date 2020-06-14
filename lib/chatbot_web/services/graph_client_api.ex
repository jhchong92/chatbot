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
    IO.puts "send_message"
    headers = [{"Content-type", "application/json"}]

    body = %{
      recipient: %{
        id: user.id
      },
      message: %{
        text: message,
      }
    }
    body =
      if length(quick_replies) > 0 do
        put_in(body, [:message, :quick_replies], quick_replies)
      else
        body
      end


    encoded = Poison.encode!(body)
    "/me/messages"
    |>  GraphClient.post!(encoded, headers)
    |> IO.inspect
  end

  def send_response(user, response) do
    IO.puts "send_response"
    IO.inspect response
    # if (response.attachment != nil) do
    #   IO.puts "Attachment not nil"
    # end

    cond do
      Map.has_key?(response, :text) && Map.has_key?(response, :quick_replies)->
        send_message(user, response.text, response.quick_replies)
      Map.has_key?(response, :attachment) ->
        send_template(user, response)
      true ->
        {:error}
    end
  end

  def send_template(user, template) do
    IO.puts "send_template"
    headers = [{"Content-type", "application/json"}]

    body = Poison.encode!( %{
      recipient: %{
        id: user.id
      },
      message: template
    })
    "/me/messages"
    |>  GraphClient.post!(body, headers)
  end
end
