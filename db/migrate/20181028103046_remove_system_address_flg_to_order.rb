class RemoveSystemAddressFlgToOrder < ActiveRecord::Migration[5.0]
  def up
    remove_column :orders, :system_address_flg
  end

  def down
    add_column :orders, :system_address_flg, :boolean
  end
end
