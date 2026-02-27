class CreateOtpCodes < ActiveRecord::Migration[8.0]
  def change
    create_table :otp_codes do |t|
      t.string :phone_number, null: false
      t.string :code, null: false
      t.datetime :expires_at, null: false
      t.integer :attempts, null: false, default: 0

      t.timestamps
    end
    add_index :otp_codes, :phone_number
    add_index :otp_codes, :expires_at
  end
end
