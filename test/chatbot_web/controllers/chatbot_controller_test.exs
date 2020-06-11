defmodule ChatbotWeb.ChatbotControllerTest do
  use ChatbotWeb.ConnCase

  test '#hello world', %{conn: conn} do
    conn = get(conn, "/api")
    assert %{
      "message" => "Hello World"
    } == json_response(conn, 200)
  end
end
