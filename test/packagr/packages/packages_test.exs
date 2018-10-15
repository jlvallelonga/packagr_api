defmodule Packagr.PackagesTest do
  use Packagr.DataCase

  alias Packagr.Packages
  alias Packagr.Packages.Package

  setup_all do
    on_exit(fn ->
      File.rm_rf("temp/")
    end)
  end

  describe "create_package" do
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

    test "create_package/1 with a text file instead of a gzipped tarball returns error" do
      File.write("temp/foo.txt", "some text")

      assert {:error, :eof} = Packages.create_package("temp/foo.txt")
    end

    test "create_package/1 with archive that doesn't include packagr.yml file returns error" do
      files = [
        {'example/example.js', "console.log(\"this is an example package\");\n"},
        {'example/something.txt', "name: example\nversion: 0.0.1\n"}
      ]

      :erl_tar.create("temp/package.tar.gz", files, [:compressed])

      assert {:error, :missing_packagr_file} = Packages.create_package("temp/package.tar.gz")
    end

    test "create_package/1 with packagr.yml file that doesn't include name or version returns error" do
      files = [
        {'example/example.js', "console.log(\"this is an example package\");\n"},
        {'example/packagr.yml', "foo: example\nbar: 0.0.1\n"}
      ]

      :erl_tar.create("temp/package.tar.gz", files, [:compressed])

      assert {:error, :missing_file_data} = Packages.create_package("temp/package.tar.gz")
    end
  end

  describe "list_packages" do
    setup do
      insert(:package)
      insert(:package)
      {:ok, %{}}
    end

    test "list_packages/0 returns a list of all packages" do
      packages = Packages.list_packages()

      refute packages == []

      assert Enum.all?(packages, fn
               %Package{id: id} when is_integer(id) -> true
               _ -> false
             end)
    end
  end

  describe "search_packages" do
    setup do
      insert(:package, %{name: "example"})
      insert(:package, %{name: "example"})
      {:ok, %{}}
    end

    test "search_packages/1 returns a list of packages with names that match the search query" do
      insert(:package, %{name: "foo"})
      packages = Packages.search_packages("example")

      refute packages == []

      assert Enum.all?(packages, fn
               %Package{name: name} -> name == "example"
               _ -> false
             end)
    end
  end

  describe "get_package" do
    setup do
      package_name = "example"
      insert(:package, %{name: package_name, version: "0.0.1"})
      insert(:package, %{name: package_name, version: "0.0.2"})

      {:ok, %{package_name: package_name}}
    end

    test "get_package/1 returns the latest version of the package with the given name", %{
      package_name: package_name
    } do
      package = Packages.get_package(package_name)
      assert package.name == package_name
      assert package.version == "0.0.2"
    end

    test "get_package/2 returns the specified version of the package with the given name", %{
      package_name: package_name
    } do
      package = Packages.get_package(package_name, "0.0.1")
      assert package.name == package_name
      assert package.version == "0.0.1"
    end

    test "get_package/1 returns nil when a package_name is given that doesn't match any existing packages" do
      package = Packages.get_package("non-existing-package-name")
      assert package == nil
    end

    test "get_package/2 returns nil when a package_name is given that doesn't match any existing packages" do
      package = Packages.get_package("non-existing-package-name", "0.0.1")
      assert package == nil
    end
  end
end
