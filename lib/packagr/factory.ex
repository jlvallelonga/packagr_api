defmodule Packagr.Factory do
  use ExMachina.Ecto, repo: Packagr.Repo

  def package_factory do
    %Packagr.Packages.Package{
      name: Faker.Cat.En.name() |> String.downcase(),
      version: Faker.format("#.#.#"),
      compressed_package: "some package data"
    }
  end
end
