class AddDrunkToUsers < ActiveRecord::Migration[8.1]
  def change
    add_column :users, :drunk, :boolean, null: false, default: false
  end
end
