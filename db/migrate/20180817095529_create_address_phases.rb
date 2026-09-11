class CreateAddressPhases < ActiveRecord::Migration[5.0]
  def change
    create_table :address_phases do |t|
      t.integer :phase, default: 1
      t.integer :line_user_id, null:false

      t.timestamps
    end
  end
end
