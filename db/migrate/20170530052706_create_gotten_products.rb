class CreateGottenProducts < ActiveRecord::Migration[5.0]
  def change
    create_table :gotten_products do |t|
      t.integer :click_num
      t.integer :product_id, null: false

      t.timestamps
    end
  end
end
