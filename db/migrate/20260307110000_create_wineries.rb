class CreateWineries < ActiveRecord::Migration[8.1]
  def change
    create_table :wineries do |t|
      t.string :name, null: false
      t.string :normalized_name, null: false

      t.timestamps
    end

    add_index :wineries, :normalized_name, unique: true
  end
end
