class AddAddressCityToOrder < ActiveRecord::Migration[5.0]
  def change
    add_column :orders, :address_city, :string
  end
end
