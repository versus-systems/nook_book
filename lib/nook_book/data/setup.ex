defmodule NookBook.Data.Setup do
  def setup() do
    :mnesia.start()
    create_schema()
  end

  def create_schema() do
    case schema_exists_anywhere?() do
      true ->
        {:ok, :already_created}

      false ->
        Enum.each(Node.list([:visible]), fn n -> Node.spawn_link(n, &:mnesia.stop/0) end)
        :mnesia.stop()
        :mnesia.create_schema(nodes())
        :mnesia.start()
        Enum.map(Node.list([:visible]), fn n -> Node.spawn_link(n, &:mnesia.start/0) end)
    end
  end

  def nodes(), do: [node() | Node.list([:visible])]

  def schema_exists_anywhere?() do
    {answers, _} = :rpc.multicall(nodes(), NookBook.Data.Setup, :schema_exists?, [])
    Enum.any?(answers, fn x -> x end)
  end

  def schema_exists?() do
    :mnesia.table_info(:schema, :disc_copies) != []
  end
end
