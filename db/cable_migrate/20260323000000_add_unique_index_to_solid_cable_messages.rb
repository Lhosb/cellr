# Rails 8.1.2 has a bug in InsertAll#find_unique_index_for where
# schema_cache.primary_keys returns nil on secondary database connections
# (such as the cable connection), causing SolidCable::Message.insert to raise:
#   ArgumentError: No unique index found for id
#
# Adding an explicit unique secondary index on `id` gives ActiveRecord a
# detectable unique index to use as the ON CONFLICT target, bypassing the
# broken primary-key detection code path. The index is logically redundant
# (id is already the primary key) but required until Rails >= 8.1.3.
class AddUniqueIndexToSolidCableMessages < ActiveRecord::Migration[8.1]
  def change
    add_index :solid_cable_messages, :id,
      unique: true,
      name: "index_solid_cable_messages_on_id"
  end
end
