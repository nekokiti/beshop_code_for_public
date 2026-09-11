class CreatePayers < ActiveRecord::Migration[5.0]
  def change
    create_table :payers do |t|
      t.string :zip
      t.string :address_country
      t.string :address_state
      t.string :address_street
      t.string :first_name
      t.string :last_name
      t.string :email
      t.string :payer_id
      t.integer :line_user_id, null:false
      t.timestamps
    end
  end
end
