class AddIsDefaultToCellarMemberships < ActiveRecord::Migration[8.1]
  def change
    add_column :cellar_memberships, :is_default, :boolean, null: false, default: false
    add_index :cellar_memberships, :user_id, unique: true, where: "is_default = true", name: "index_cellar_memberships_on_user_id_where_default"
  end
end
