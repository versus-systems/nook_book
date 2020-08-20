defmodule NookBookWeb.ImageController do
  use NookBookWeb, :controller
  alias NookBook.ACNH.Cache, as: Cache

  @collection_functions %{
    "bugs" => %{icon: &Cache.bug_icon/1, image: &Cache.bug_image/1},
    "fish" => %{icon: &Cache.fish_icon/1, image: &Cache.fish_image/1},
    "sea_creatures" => %{icon: &Cache.sea_creature_icon/1, image: &Cache.sea_creature_image/1}
  }

  def icon(conn, %{"namespace" => namespace, "id" => id}) do
    file =
      id
      |> String.to_integer()
      |> @collection_functions[namespace].icon.()

    conn
    |> put_resp_content_type("image/png", "utf-8")
    |> send_resp(200, file)
  end

  def image(conn, %{"namespace" => namespace, "id" => id}) do
    file =
      id
      |> String.to_integer()
      |> @collection_functions[namespace].image.()

    conn
    |> put_resp_content_type("image/png", "utf-8")
    |> send_resp(200, file)
  end
end
