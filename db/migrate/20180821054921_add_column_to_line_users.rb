class AddColumnToLineUsers < ActiveRecord::Migration[5.0]
  def change
    add_column :line_users, :zip, :string
    add_column :line_users, :address_country, :string
    add_column :line_users, :address_state, :string
    add_column :line_users, :address_street, :string
    add_column :line_users, :first_name, :string
    add_column :line_users, :last_name, :string
  end
end
