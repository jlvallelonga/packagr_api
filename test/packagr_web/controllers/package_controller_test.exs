defmodule PackagrWeb.PackageControllerTest do
  use PackagrWeb.ConnCase

  setup_all do
    on_exit(fn ->
      File.rm_rf("temp/")
    end)
  end

  setup %{conn: conn} do
    {:ok, conn: put_req_header(conn, "accept", "application/json")}
  end

  describe "create package" do
    setup do
      File.rm_rf("temp/")
      File.mkdir("temp/")
    end

    test "renders package when data is valid", %{conn: conn} do
      package_name = "example"
      package_version = "0.0.1"

      files = [
        {'example/example.js', "console.log(\"this is an example package\");\n"},
        {'example/packagr.yml', "name: #{package_name}\nversion: #{package_version}\n"}
      ]

      :erl_tar.create("temp/package.tar.gz", files, [:compressed])

      package_upload = %Plug.Upload{path: "temp/package.tar.gz", filename: "package.tar.gz"}

      conn = post(conn, package_path(conn, :create), package: package_upload)
      assert resp = %{} = json_response(conn, 201)["data"]

      assert resp |> Map.get("id") |> is_integer
      assert resp |> Map.get("name") == package_name
      assert resp |> Map.get("version") == package_version
    end

    test "renders errors when data is invalid", %{conn: conn} do
      File.write("temp/foo.txt", "some text")
      package_upload = %Plug.Upload{path: "temp/foo.txt", filename: "foo.txt"}
      conn = post(conn, package_path(conn, :create), package: package_upload)
      assert %{"error" => "invalid file data"} = json_response(conn, 422)
    end
  end
end