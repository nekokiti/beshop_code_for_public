class CreateCashOnDeliveryInfos < ActiveRecord::Migration[5.0]
  def change
    create_table :cash_on_delivery_infos do |t|
      t.integer :price, default: 0
      t.references :company, foreign_key: true
      t.boolean :enable_flg, default: false
      t.timestamps
    end
  end
end
