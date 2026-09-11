class AddColumnToOrderProduct < ActiveRecord::Migration[5.0]
  def change
    add_column :order_products, :product_name, :string
    add_column :order_products, :product_price, :integer
    add_column :order_products, :size_name, :string
  end
end
