class AddAddressSetFlgToLineUser < ActiveRecord::Migration[5.0]
  def change
    add_column :line_users, :address_set_flg, :boolean, default: false
  end
end
