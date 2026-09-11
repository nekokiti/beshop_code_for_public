class AddColumnToProduct < ActiveRecord::Migration[5.0]
  def change
    add_column :products, :price, :int
    add_column :products, :quantity, :int
  end
end
