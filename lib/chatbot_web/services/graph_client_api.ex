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

end
