class CreateAdminRoles < ActiveRecord::Migration[8.0]
  def change
    create_table :admin_roles do |t|
      t.references :user, null: false, foreign_key: true
      t.references :venue, null: false, foreign_key: true
      t.string :role, null: false
      t.timestamps
    end
  end
end
