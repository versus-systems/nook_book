defmodule NookBook.ACNH.API.Client do
  require Logger
  alias NookBook.ACNH.API.Client.Private
  use Tesla
  plug(Tesla.Middleware.BaseUrl, "https://acnhapi.com/v1a")
  plug(Tesla.Middleware.JSON)

  def bugs() do
    "/bugs/"
    |> get()
    |> Private.unwrap_response()
  end

  def bug(id) do
    "/bugs/#{id}"
    |> get()
    |> Private.unwrap_response()
  end

  def bug_icon(id) do
    "/icons/bugs/#{id}"
    |> get()
    |> Private.unwrap_response()
  end

  def bug_image(id) do
    "/images/bugs/#{id}"
    |> get()
    |> Private.unwrap_response()
  end

  def fish() do
    "/fish/"
    |> get()
    |> Private.unwrap_response()
  end

  def fish(id) do
    "/fish/#{id}"
    |> get()
    |> Private.unwrap_response()
  end

  def fish_icon(id) do
    "/icons/fish/#{id}"
    |> get()
    |> Private.unwrap_response()
  end

  def fish_image(id) do
    "/images/fish/#{id}"
    |> get()
    |> Private.unwrap_response()
  end

  def sea_creatures() do
    "/sea/"
    |> get()
    |> Private.unwrap_response()
  end

  def sea_creature(id) do
    "/sea/#{id}"
    |> get()
    |> Private.unwrap_response()
  end

  def sea_creature_icon(id) do
    "/icons/sea/#{id}"
    |> get()
    |> Private.unwrap_response()
  end

  def sea_creature_image(id) do
    "/images/sea/#{id}"
    |> get()
    |> Private.unwrap_response()
  end

  defmodule Private do
    def unwrap_response({:ok, %Tesla.Env{body: body, status: 200}}), do: body

    def unwrap_response(response) do
      response
      |> inspect()
      |> Logger.info()

      nil
    end
  end
end
