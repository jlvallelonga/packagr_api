defmodule Packagr.PackageTest do
  use Packagr.DataCase

  alias Packagr.Packages.Package

  test "changeset with valid attrs" do
    package_attrs = %{
      name: "package-name",
      version: "0.0.1",
      compressed_package: "archive file contents"
    }

    changeset = Package.changeset(%Package{}, package_attrs)
    assert changeset.valid?
  end

  test "changeset with missing name, version, and compressed_package" do
    package_attrs = %{}

    changeset = Package.changeset(%Package{}, package_attrs)
    refute changeset.valid?

    assert changeset.errors == [
             name: {"can't be blank", [validation: :required]},
             version: {"can't be blank", [validation: :required]},
             compressed_package: {"can't be blank", [validation: :required]}
           ]
  end

  test "changeset with present but empty name, version, and compressed_package" do
    package_attrs = %{name: "", version: "", compressed_package: ""}

    changeset = Package.changeset(%Package{}, package_attrs)
    refute changeset.valid?

    assert changeset.errors == [
             name: {"can't be blank", [validation: :required]},
             version: {"can't be blank", [validation: :required]},
             compressed_package: {"can't be blank", [validation: :required]}
           ]
  end

  test "changeset with name and version that are too long" do
    name = Enum.reduce(1..256, "", fn _, acc -> acc <> "a" end)
    version = Enum.reduce(1..252, "", fn _, acc -> acc <> "1" end) <> ".0.0"
    package_attrs = %{name: name, version: version, compressed_package: "some compressed data"}

    changeset = Package.changeset(%Package{}, package_attrs)
    refute changeset.valid?

    assert changeset.errors == [
             version:
               {"should be at most %{count} character(s)",
                [count: 255, validation: :length, max: 255]},
             name:
               {"should be at most %{count} character(s)",
                [count: 255, validation: :length, max: 255]}
           ]
  end

  test "changeset with name and version that are invalid formats" do
    name = "Apackage"
    version = "abc"
    package_attrs = %{name: name, version: version, compressed_package: "some compressed data"}

    changeset = Package.changeset(%Package{}, package_attrs)
    refute changeset.valid?

    assert changeset.errors == [
             version: {"has invalid format", [validation: :format]},
             name: {"has invalid format", [validation: :format]}
           ]
  end

  test "changeset with name and version combination that has been used already" do
    package_attrs = %{
      name: "package-name",
      version: "0.0.1",
      compressed_package: "archive file contents"
    }

    Package.changeset(%Package{}, package_attrs)
    |> Repo.insert()

    {:error, changeset} =
      Package.changeset(%Package{}, package_attrs)
      |> Repo.insert()

    refute changeset.valid?

    assert changeset.errors == [version: {"has already been taken", []}]
  end
end
