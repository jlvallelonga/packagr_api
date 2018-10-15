defmodule PackagrWeb.Router do
  use PackagrWeb, :router

  pipeline :api do
    plug(:accepts, ["json"])
  end

  scope "/api", PackagrWeb do
    pipe_through(:api)

    resources("/packages", PackageController, only: [:create, :index])
    get("/packages/:package_name", PackageController, :get_package)
  end
end
