class CreateDrinkingSessions < ActiveRecord::Migration[8.1]
  def change
    create_table :drinking_sessions do |t|
      t.references :user, null: false, foreign_key: true
      t.date :date, null: false
      t.datetime :started_at, null: false
      t.datetime :ended_at
      t.datetime :last_activity_at, null: false

      t.timestamps
    end

    add_index :drinking_sessions, [ :user_id, :date ], unique: true
    add_index :drinking_sessions,
              [ :date, :ended_at, :last_activity_at, :id ],
              order: { last_activity_at: :desc, id: :desc },
              name: "index_drinking_sessions_on_active_feed"

    add_check_constraint :drinking_sessions,
                         "ended_at IS NULL OR ended_at >= started_at",
                         name: "check_drinking_sessions_ended_after_start"
  end
end
