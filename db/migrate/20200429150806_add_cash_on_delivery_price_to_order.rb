class AddCashOnDeliveryPriceToOrder < ActiveRecord::Migration[5.0]
  def change
    add_column :orders, :cash_on_delivery_price, :integer, default: 0
  end
end
