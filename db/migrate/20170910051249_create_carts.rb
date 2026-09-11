class CreateCarts < ActiveRecord::Migration[5.0]
  def change
    create_table :carts do |t|
      t.integer :line_user_id, null:false
      t.timestamps
    end
  end
end
