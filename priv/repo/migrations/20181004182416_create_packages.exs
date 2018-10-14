defmodule Packagr.Repo.Migrations.CreatePackages do
  use Ecto.Migration

  def change do
    create table(:packages) do
      add :name, :string, null: false
      add :version, :string, null: false
      add :compressed_package, :bytea, null: false

      timestamps()
    end

    create unique_index(:packages, [:name, :version], name: :packages_name_version_index)
  end
end
