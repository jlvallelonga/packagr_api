defmodule Packagr.Authenticate do
  import Plug.Conn

  def init(options) do
    options
  end

  def call(conn, _opts) do
    user = Plug.Conn.get_req_header(conn, "x-auth-user") |> List.first()
    password = Plug.Conn.get_req_header(conn, "x-auth-password") |> List.first()

    if user == "foo" && password == "bar" do
      conn
    else
      conn
      |> put_status(:forbidden)
      |> Phoenix.Controller.json(%{"error" => "forbidden"})
      |> halt
    end
  end
end
