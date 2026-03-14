class AddUniqueIndexToDrinkingSessions < ActiveRecord::Migration[8.1]
  def change
    unless index_exists?(:drinking_sessions, [ :user_id, :date ], unique: true)
      add_index :drinking_sessions, [ :user_id, :date ], unique: true
    end
  end
end
