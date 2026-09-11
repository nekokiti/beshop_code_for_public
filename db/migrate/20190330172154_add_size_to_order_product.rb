class AddSizeToOrderProduct < ActiveRecord::Migration[5.0]
  def change
    add_column :order_products, :size_id, :integer
  end
end
