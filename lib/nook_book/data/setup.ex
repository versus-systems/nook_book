defmodule NookBook.Data.Setup do
  import Logger

  @tables [
    NookBook.Data.GenericCache
  ]

  def setup(:primary) do
    Logger.info("Setting up mnesia for primary node")
    :mnesia.start()
    create_schema()
    create_tables()
  end

  def setup(:member) do
    Logger.info("Setting up mnesia for member node, cluster peers:")
    Logger.info(inspect(nodes()))

    [existing_node | _] = Node.list([:visible])
    name = Node.self()

    :mnesia.start()
    {:ok, _} = :rpc.call(existing_node, :mnesia, :change_config, [:extra_db_nodes, [name]])

    :mnesia.change_table_copy_type(:schema, name, :disc_copies)
    :mnesia.add_table_copy(:schema, name, :disc_copies)
    sync_remote_tables_to_local_disk()
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

  def create_tables() do
    @tables
    |> Enum.each(&create_table/1)
  end

  def create_table(module) do
    case table_exists?(module.table_name()) do
      true ->
        {:ok, :already_created}

      false ->
        :mnesia.create_table(
          module.table_name(),
          attributes: module.table_fields(),
          type: module.table_type(),
          index: module.table_indexes(),
          disc_copies: nodes()
        )
    end
  end

  def table_exists?(table_name) do
    Enum.member?(:mnesia.system_info(:tables), table_name)
  end

  def wait_for_tables() do
    :mnesia.wait_for_tables(table_names(), 10_000)
  end

  def table_names(), do: @tables |> Enum.map(&apply(&1, :table_name, []))

  def sync_remote_tables_to_local_disk() do
    name = Node.self()

    :mnesia.system_info(:tables)
    |> Enum.each(fn table ->
      case Node.self() in :mnesia.table_info(table, :disc_copies) do
        true ->
          :ok

        false ->
          Logger.info("Syncing #{table}")
          :mnesia.add_table_copy(table, name, :disc_copies)
      end
    end)
  end
end
