defmodule Packagr.Packages.Package do
  use Ecto.Schema
  import Ecto.Changeset

  schema "packages" do
    field(:name, :string)
    field(:version, :string)
    field(:compressed_package, :binary)

    timestamps()
  end

  @doc false
  def changeset(package, attrs) do
    package
    |> cast(attrs, [:name, :version, :compressed_package])
    |> validate_required([:name, :version, :compressed_package])
    |> validate_length(:name, max: 255)
    |> validate_length(:version, max: 255)
    |> validate_format(:name, ~r/^[a-z0-9\-]*$/)
    |> validate_format(:version, ~r/^\d+\.\d+\.\d+$/)
    |> unique_constraint(:version, name: :packages_name_version_index)
  end
end
