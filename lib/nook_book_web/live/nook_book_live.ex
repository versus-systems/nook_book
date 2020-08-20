defmodule NookBookWeb.NookBookLive do
  use NookBookWeb, :live_view
  alias NookBook.ACNH.Cache, as: Cache

  @collection_functions %{
    "bugs" => %{list: &Cache.bugs/0, record: &Cache.bug/1},
    "fish" => %{list: &Cache.fish/0, record: &Cache.fish/1},
    "sea_creatures" => %{list: &Cache.sea_creatures/0, record: &Cache.sea_creature/1}
  }

  @impl true
  def mount(_params, _session, socket) do
    {:ok,
     assign(socket, %{
       toggles: %{
         "bugs" => false,
         "fish" => false,
         "sea_creatures" => false
       },
       collections: %{
         "bugs" => [],
         "fish" => [],
         "sea_creatures" => []
       },
       record: nil
     })}
  end

  @impl true
  def handle_event("toggle", %{"collection" => name}, socket) do
    section_collection =
      if !socket.assigns.toggles[name] do
        @collection_functions[name].list.()
        |> Enum.map(fn record ->
          %{
            id: record["id"],
            name: String.capitalize(record["name"]["name-USen"]),
            icon: "/icons/#{name}/#{record["id"]}"
          }
        end)
      else
        []
      end

    {:noreply,
     assign(socket, %{
       toggles: Map.put(socket.assigns.toggles, name, !socket.assigns.toggles[name]),
       collections: Map.put(socket.assigns.collections, name, section_collection)
     })}
  end

  @impl true
  def handle_event("show", %{"collection" => name, "id" => id}, socket) do
    record =
      case @collection_functions[name].record.(String.to_integer(id)) do
        nil ->
          nil

        record ->
          %{
            name: String.capitalize(record["name"]["name-USen"]),
            image: "/images/#{name}/#{record["id"]}",
            price: record["price"]
          }
      end

    {:noreply, assign(socket, %{record: record})}
  end

  @impl true
  def handle_event("hide", _params, socket) do
    {:noreply, assign(socket, %{record: nil})}
  end
end
