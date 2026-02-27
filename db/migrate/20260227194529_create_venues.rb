class CreateVenues < ActiveRecord::Migration[8.0]
  def change
    create_table :venues do |t|
      t.string :name, null: false
      t.text :description
      t.string :address
      t.references :venue_admin, null: false, foreign_key: true

      t.timestamps
    end
  end
end
