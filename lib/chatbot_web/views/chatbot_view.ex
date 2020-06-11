defmodule ChatbotWeb.ChatbotView do
    use ChatbotWeb, :view

    def render("hello.json", _params) do
      %{
        message: "Hello World!"
      }
    end
end
