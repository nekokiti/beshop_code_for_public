class ChageColumnToProduct < ActiveRecord::Migration[5.0]
  def change
    change_column :products, :quantity, :int, default: 0
  end
end
