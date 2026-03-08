class RenameIsDefaultOnCellarMemberships < ActiveRecord::Migration[8.1]
  class MigrationCellarMembership < ApplicationRecord
    self.table_name = "cellar_memberships"
  end

  def up
    if column_exists?(:cellar_memberships, :is_default)
      rename_column :cellar_memberships, :is_default, :default
    end

    remove_index :cellar_memberships, name: "index_cellar_memberships_on_user_id_where_default", if_exists: true
    add_index :cellar_memberships, :user_id, unique: true, where: '"default" = true', name: "index_cellar_memberships_on_user_id_where_default"

    MigrationCellarMembership.reset_column_information

    say_with_time "Backfilling default cellar memberships by earliest cellar created_at" do
      MigrationCellarMembership.update_all(default: false)

      MigrationCellarMembership.distinct.pluck(:user_id).each do |user_id|
        membership = MigrationCellarMembership
          .joins("INNER JOIN cellars ON cellars.id = cellar_memberships.cellar_id")
          .where(user_id: user_id)
          .order(Arel.sql("cellars.created_at ASC, cellar_memberships.created_at ASC, cellar_memberships.id ASC"))
          .first

        membership&.update_columns(default: true, updated_at: Time.current)
      end
    end
  end

  def down
    remove_index :cellar_memberships, name: "index_cellar_memberships_on_user_id_where_default", if_exists: true

    if column_exists?(:cellar_memberships, :default)
      rename_column :cellar_memberships, :default, :is_default
    end

    add_index :cellar_memberships, :user_id, unique: true, where: "is_default = true", name: "index_cellar_memberships_on_user_id_where_default"
  end
end
