defmodule ChatbotWeb.ChatbotController do
  use ChatbotWeb, :controller

  def hello(conn, _params) do
    render(conn, "hello.json")
  end
end
