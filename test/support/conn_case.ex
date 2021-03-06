defmodule PackagrWeb.ConnCase do
  @moduledoc """
  This module defines the test case to be used by
  tests that require setting up a connection.

  Such tests rely on `Phoenix.ConnTest` and also
  import other functionality to make it easier
  to build common datastructures and query the data layer.

  Finally, if the test case interacts with the database,
  it cannot be async. For this reason, every test runs
  inside a transaction which is reset at the beginning
  of the test unless the test case is marked as async.
  """

  use ExUnit.CaseTemplate

  using do
    quote do
      # Import conveniences for testing with connections
      use Phoenix.ConnTest
      import PackagrWeb.Router.Helpers
      import Packagr.Factory

      # The default endpoint for testing
      @endpoint PackagrWeb.Endpoint
    end
  end

  setup tags do
    :ok = Ecto.Adapters.SQL.Sandbox.checkout(Packagr.Repo)

    unless tags[:async] do
      Ecto.Adapters.SQL.Sandbox.mode(Packagr.Repo, {:shared, self()})
    end

    authed_conn = Phoenix.ConnTest.build_conn()
    |> Plug.Conn.put_req_header("x-auth-user", "foo")
    |> Plug.Conn.put_req_header("x-auth-password", "bar")

    unauthed_conn = Phoenix.ConnTest.build_conn()

    {:ok, conn: authed_conn, unauthed_conn: unauthed_conn}
  end
end
