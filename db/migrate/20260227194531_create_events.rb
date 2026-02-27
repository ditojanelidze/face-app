class CreateEvents < ActiveRecord::Migration[8.0]
  def change
    create_table :events do |t|
      t.references :venue, null: false, foreign_key: true
      t.string :name, null: false
      t.text :description
      t.datetime :date_time, null: false
      t.boolean :allow_global_approval, null: false, default: true

      t.timestamps
    end
    add_index :events, :date_time
  end
end
