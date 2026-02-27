class CreateSessions < ActiveRecord::Migration[8.0]
  def change
    create_table :sessions do |t|
      t.references :user, null: false, foreign_key: true
      t.string :refresh_token, null: false
      t.datetime :expires_at, null: false
      t.string :device_info

      t.timestamps
    end
    add_index :sessions, :refresh_token, unique: true
    add_index :sessions, :expires_at
  end
end
