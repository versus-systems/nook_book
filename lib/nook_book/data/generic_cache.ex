defmodule NookBook.Data.GenericCache do
  @behaviour NookBook.Data.TableBehaviour
  require Record

  Record.defrecord(:generic_cache, key: nil, value: nil)

  def table_name(), do: :generic_cache
  def table_type(), do: :set
  def table_fields(), do: [:key, :value]
  def table_indexes(), do: []
end
