defmodule Packagr.PackagesTest do
  use Packagr.DataCase

  alias Packagr.Packages

  setup_all do
    on_exit(fn ->
      File.rm_rf("temp/")
    end)
  end

  describe "packages" do
    alias Packagr.Packages.Package

    setup do
      File.rm_rf("temp/")
      File.mkdir("temp/")
    end

    test "create_package/1 with valid data creates a package" do
      files = [
        {'example/example.js', "console.log(\"this is an example package\");\n"},
        {'example/packagr.yml', "name: example\nversion: 0.0.1\n"}
      ]

      :erl_tar.create("temp/package.tar.gz", files, [:compressed])

      assert {:ok, %Package{} = package} = Packages.create_package("temp/package.tar.gz")
      assert package.id |> is_integer()
      assert package.name == "example"
      assert package.version == "0.0.1"
    end

    test "create_package/1 with non-existent file returns error" do
      assert {:error, :enoent} = Packages.create_package("temp/does-not-exist.tar.gz")
    end

    test "create_package/1 with a text file instead of a gzipped tarball" do
      File.write("temp/foo.txt", "some text")

      assert {:error, :eof} = Packages.create_package("temp/foo.txt")
    end

    test "create_package/1 with archive that doesn't include packagr.yml file" do
      files = [
        {'example/example.js', "console.log(\"this is an example package\");\n"},
        {'example/something.txt', "name: example\nversion: 0.0.1\n"}
      ]

      :erl_tar.create("temp/package.tar.gz", files, [:compressed])

      assert {:error, :missing_packagr_file} = Packages.create_package("temp/package.tar.gz")
    end

    test "create_package/1 with packagr.yml file that doesn't include name or version" do
      files = [
        {'example/example.js', "console.log(\"this is an example package\");\n"},
        {'example/packagr.yml', "foo: example\nbar: 0.0.1\n"}
      ]

      :erl_tar.create("temp/package.tar.gz", files, [:compressed])

      assert {:error, :missing_file_data} = Packages.create_package("temp/package.tar.gz")
    end
  end
end
