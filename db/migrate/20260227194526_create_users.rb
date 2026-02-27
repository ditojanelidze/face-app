class CreateUsers < ActiveRecord::Migration[8.0]
  def change
    create_table :users do |t|
      t.string :first_name, null: false
      t.string :last_name, null: false
      t.string :phone_number, null: false
      t.boolean :phone_verified, default: false, null: false
      t.jsonb :social_links, default: {}
      t.string :role, default: "customer", null: false

      t.timestamps
    end
    add_index :users, :phone_number, unique: true
  end
end
