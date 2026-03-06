class CreateCellrCoreSchema < ActiveRecord::Migration[8.1]
  def change
    enable_extension "pg_trgm" unless extension_enabled?("pg_trgm")

    create_table :users do |t|
      t.string :email, null: false
      t.string :name

      t.timestamps
    end

    add_index :users, :email, unique: true

    create_table :cellars do |t|
      t.references :owner, null: false, foreign_key: { to_table: :users }
      t.string :name, null: false

      t.timestamps
    end

    create_table :cellar_memberships do |t|
      t.references :cellar, null: false, foreign_key: true
      t.references :user, null: false, foreign_key: true
      t.integer :role, null: false, default: 0

      t.timestamps
    end

    add_index :cellar_memberships, [ :cellar_id, :user_id ], unique: true

    create_table :cellar_invitations do |t|
      t.references :cellar, null: false, foreign_key: true
      t.references :invited_by, null: false, foreign_key: { to_table: :users }
      t.string :email, null: false
      t.integer :role, null: false, default: 2
      t.string :token, null: false
      t.datetime :accepted_at

      t.timestamps
    end

    add_index :cellar_invitations, :token, unique: true

    create_table :wines do |t|
      t.references :cellar, null: false, foreign_key: true
      t.string :winery, null: false
      t.string :normalized_winery, null: false
      t.string :wine_name, null: false
      t.string :normalized_wine_name, null: false
      t.integer :vintage
      t.string :varietal
      t.string :wine_type
      t.string :region
      t.integer :bottle_size_ml
      t.integer :purchase_price_cents, null: false, default: 0
      t.string :canonical_key, null: false

      t.timestamps
    end

    add_index :wines, [ :cellar_id, :canonical_key ], unique: true
    add_index :wines, :normalized_winery
    add_index :wines, :normalized_wine_name
    add_index :wines, :winery, using: :gin, opclass: :gin_trgm_ops
    add_index :wines, :wine_name, using: :gin, opclass: :gin_trgm_ops

    create_table :tags do |t|
      t.references :cellar, null: false, foreign_key: true
      t.string :name, null: false

      t.timestamps
    end

    add_index :tags, [ :cellar_id, :name ], unique: true

    create_table :wine_tags do |t|
      t.references :wine, null: false, foreign_key: true
      t.references :tag, null: false, foreign_key: true

      t.timestamps
    end

    add_index :wine_tags, [ :wine_id, :tag_id ], unique: true
  end
end
