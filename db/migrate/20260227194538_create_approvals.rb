class CreateApprovals < ActiveRecord::Migration[8.0]
  def change
    create_table :approvals do |t|
      t.references :user, null: false, foreign_key: true
      t.references :venue, null: false, foreign_key: true
      t.references :event, null: true, foreign_key: true
      t.integer :approval_type, null: false, default: 0
      t.integer :status, null: false, default: 0
      t.text :qr_code_data
      t.datetime :expires_at
      t.boolean :qr_used, null: false, default: false

      t.timestamps
    end
    add_index :approvals, [:user_id, :venue_id, :event_id], unique: true, name: 'index_approvals_uniqueness'
    add_index :approvals, :status
    add_index :approvals, :qr_code_data, unique: true
  end
end
