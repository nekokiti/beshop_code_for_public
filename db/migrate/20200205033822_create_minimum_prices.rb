class CreateMinimumPrices < ActiveRecord::Migration[5.0]
  def change
    create_table :minimum_prices do |t|
      t.integer :company_id, null: false
      t.integer :price, default: nil
      t.timestamps
    end
  end
end
