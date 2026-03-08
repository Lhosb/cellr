class RemoveDrunkFromUsers < ActiveRecord::Migration[8.1]
  def change
    remove_column :users, :drunk, :boolean, null: false, default: false
  end
end
