class CreateShippings < ActiveRecord::Migration[5.0]
  def change
    create_table :shippings do |t|
      t.integer :shipping_fee
      t.integer :extra_fee
      t.integer :company_id

      t.timestamps
    end
  end
end
