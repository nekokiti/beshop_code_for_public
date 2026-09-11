class CreateShippingInfos < ActiveRecord::Migration[5.0]
  def change
    create_table :shipping_infos do |t|
      t.datetime :shipping_day, null: false
      t.string :shipping_company, null: false
      t.integer :shipping_number
      t.references :order, foreign_key: true
      t.timestamps
    end
  end
end
