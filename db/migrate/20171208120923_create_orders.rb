class CreateOrders < ActiveRecord::Migration[5.0]
  def change
    create_table :orders do |t|
      t.integer :line_user_id, null:false
      t.string :token
      t.boolean :verified

      t.timestamps
    end
  end
end
