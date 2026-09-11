class AddAddressStreetByPostalCodeToLineUser < ActiveRecord::Migration[5.0]
  def change
    add_column :line_users, :address_street_by_postal_code, :string, default: ""
  end
end
