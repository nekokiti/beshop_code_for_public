class AddSizeToCartProduct < ActiveRecord::Migration[5.0]
  def change
    add_column :cart_products, :size_id, :integer
  end
end
