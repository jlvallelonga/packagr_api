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
      _ ->
        conn
        |> put_status(:unprocessable_entity)
        |> json(%{error: "invalid file data"})
    end
  end

  def get_package(conn, %{"package_name" => package_name, "version" => package_version}) do
    package = Packages.get_package(package_name, package_version)
    render_package(conn, package)
  end

  def get_package(conn, %{"package_name" => package_name}) do
    package = Packages.get_package(package_name)
    render_package(conn, package)
  end

  defp render_package(
         conn = %Plug.Conn{params: %{"download" => "true"}},
         package = %Package{}
       ) do
    conn
    |> send_download({:binary, package.compressed_package}, filename: package.name <> ".tar.gz")
  end

  defp render_package(conn, package = %Package{}) do
    render(conn, "show.json", package: package)
  end

  defp render_package(conn, _) do
    conn
    |> put_status(:not_found)
    |> json(%{error: "package not found"})
  end
end
