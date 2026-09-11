class RemoveColumnToOrderProduct < ActiveRecord::Migration[5.0]
  def up
    remove_column :order_products, :product_id
  end
  def down
    add_column :order_products, :product_id, :integer
  end
end
