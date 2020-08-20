defmodule NookBook.ACNH.Cache do
  alias NookBook.ACNH.Cache.Private

  def bugs() do
    Private.list_from_cache(:bug, :bugs)
  end

  def bug(id) do
    Private.record_from_cache(:bug, :bug, id)
  end

  def bug_icon(id) do
    Private.record_from_cache(:bug_icon, :bug_icon, id)
  end

  def bug_image(id) do
    Private.record_from_cache(:bug_image, :bug_image, id)
  end

  def fish() do
    Private.list_from_cache(:fish, :fish)
  end

  def fish(id) do
    Private.record_from_cache(:fish, :fish, id)
  end

  def fish_icon(id) do
    Private.record_from_cache(:fish_icon, :fish_icon, id)
  end

  def fish_image(id) do
    Private.record_from_cache(:fish_image, :fish_image, id)
  end

  def sea_creatures() do
    Private.list_from_cache(:sea_creature, :sea_creatures)
  end

  def sea_creature(id) do
    Private.record_from_cache(:sea_creature, :sea_creature, id)
  end

  def sea_creature_icon(id) do
    Private.record_from_cache(:sea_creature_icon, :sea_creature_icon, id)
  end

  def sea_creature_image(id) do
    Private.record_from_cache(:sea_creature_image, :sea_creature_image, id)
  end

  defmodule Private do
    alias NookBook.ACNH.API.Client, as: Client
    alias NookBook.Data.GenericCache, as: Cache

    def list_from_cache(namespace, function) do
      {namespace, :_}
      |> Cache.filter()
      |> case do
        [] ->
          apply(Client, function, [])
          |> Enum.reject(fn record -> is_nil(record["id"]) end)
          |> Enum.map(&Cache.set({namespace, &1["id"]}, &1))

        list ->
          list
      end
      |> Enum.sort_by(fn record -> String.capitalize(record["name"]["name-USen"]) end)
    end

    def record_from_cache(namespace, function, id) do
      {namespace, id}
      |> Cache.get()
      |> case do
        nil ->
          record = apply(Client, function, [id])
          Cache.set({namespace, id}, record)

        record ->
          record
      end
    end
  end
end
