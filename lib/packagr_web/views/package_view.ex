defmodule PackagrWeb.PackageView do
  use PackagrWeb, :view
  alias PackagrWeb.PackageView

  def render("index.json", %{packages: packages}) do
    %{packages: render_many(packages, PackageView, "package.json")}
  end

  def render("show.json", %{package: package}) do
    %{package: render_one(package, PackageView, "package.json")}
  end

  def render("package.json", %{package: package}) do
    %{id: package.id, name: package.name, version: package.version}
  end
end
