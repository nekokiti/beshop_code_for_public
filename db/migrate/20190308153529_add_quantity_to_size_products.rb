class AddQuantityToSizeProducts < ActiveRecord::Migration[5.0]
  def change
    add_column :size_products, :quantity, :integer
  end
end
