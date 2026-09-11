class ChangeColumToSizeProduct < ActiveRecord::Migration[5.0]
  def change
    change_column :size_products, :quantity, :int, default: 0
  end
end
