class AddSystemAddressFlgToOrder < ActiveRecord::Migration[5.0]
  def change
    add_column :orders, :system_address_flg, :boolean
  end
end
