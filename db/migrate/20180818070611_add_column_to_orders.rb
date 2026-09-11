class AddColumnToOrders < ActiveRecord::Migration[5.0]
  def change
    remove_column :orders, :payer_id, :integer
    add_column :orders, :zip, :string
    add_column :orders, :address_country, :string
    add_column :orders, :address_state, :string
    add_column :orders, :address_street, :string
    add_column :orders, :first_name, :string
    add_column :orders, :last_name, :string
    add_column :orders, :email, :string
  end
end
