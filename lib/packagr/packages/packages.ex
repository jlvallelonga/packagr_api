defmodule Packagr.Packages do
  @moduledoc """
  The Packages context.
  """

  import Ecto.Query, warn: false
  alias Packagr.Repo

  alias Packagr.Packages.Package

  @doc """
  Creates a package.

  ## Examples

      iex> create_package(tarball_filename)
      {:ok, %Package{}}

      iex> create_package(invalid_tarball_filename)
      {:error, error_message}

  """
  def create_package(tarball_filepath) do
    with {:ok, file_contents} <- File.read(tarball_filepath),
         {:ok, files} <- :erl_tar.extract(tarball_filepath, [:compressed, :memory]),
         {packagr_yml_file_path, packagr_yml_file_contents} when is_list(packagr_yml_file_path) <-
           get_packagr_yml_file(files),
         {:ok, yaml_map} <- YamlElixir.read_from_string(packagr_yml_file_contents),
         {:ok, name} <- Map.fetch(yaml_map, "name"),
         {:ok, version} <- Map.fetch(yaml_map, "version") do
      package_attrs = %{
        name: name,
        version: version,
        compressed_package: file_contents
      }

      %Package{}
      |> Package.changeset(package_attrs)
      |> Repo.insert()
    else
      error_tuple = {:error, _} -> error_tuple
      :error -> {:error, :missing_file_data}
      _ -> {:error, :unknown_error}
    end
  end

  defp get_packagr_yml_file(files_list) do
    files_list
    |> Enum.find({:error, :missing_packagr_file}, fn {extracted_path, _contents} ->
      extracted_path |> to_string() |> String.split("/") |> List.last() == "packagr.yml"
    end)
  end
end
