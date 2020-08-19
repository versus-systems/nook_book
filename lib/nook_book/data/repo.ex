defmodule NookBook.Data.Repo do
  def read(table, key) do
    :mnesia.transaction(fn -> :mnesia.read(table, key) end)
  end

  def write(record) do
    :mnesia.transaction(fn -> :mnesia.write(record) end)
  end

  def delete(table, key) do
    :mnesia.transaction(fn -> :mnesia.delete({table, key}) end)
  end

  def clear(table) do
    :mnesia.clear_table(table)
  end

  def all(table) do
    :mnesia.transaction(fn ->
      :mnesia.match_object(table, :mnesia.table_info(table, :wild_pattern), :read)
    end)
  end

  def filter(table, pattern) do
    :mnesia.transaction(fn ->
      :mnesia.match_object(table, pattern, :read)
    end)
  end
end
