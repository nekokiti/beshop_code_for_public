class AddDispInventoryFlgForProduct < ActiveRecord::Migration[5.0]
  def change
    add_column :products, :disp_inventory_flg, :boolean, default: false
  end
end
