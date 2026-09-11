class AddQuantityToOrderProducts < ActiveRecord::Migration[5.0]
  def change
    add_column :order_products, :quantity, :integer
  end
end
