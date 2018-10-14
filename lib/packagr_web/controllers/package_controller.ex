defmodule PackagrWeb.PackageController do
  use PackagrWeb, :controller

  alias Packagr.Packages
  alias Packagr.Packages.Package

  action_fallback(PackagrWeb.FallbackController)

  def create(conn, %{"package" => upload = %Plug.Upload{}}) do
    with {:ok, %Package{} = package} <- Packages.create_package(upload.path) do
      conn
      |> put_status(:created)
      |> render("show.json", package: package)
    else
      {_, message} ->
        conn
        |> put_status(:unprocessable_entity)
        |> json(%{error: "invalid file data"})
    end
  end
end
