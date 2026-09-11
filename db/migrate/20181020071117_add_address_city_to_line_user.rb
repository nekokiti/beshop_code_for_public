class AddAddressCityToLineUser < ActiveRecord::Migration[5.0]
  def change
    add_column :line_users, :address_city, :string
  end
end
