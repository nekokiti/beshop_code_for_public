class AddDefaultToLineUser < ActiveRecord::Migration[5.0]
  def up
    change_column :line_users, :zip, :string, default: '未設定'
    change_column :line_users, :address_country, :string, default: '未設定'
    change_column :line_users, :address_state, :string, default: '未設定'
    change_column :line_users, :address_street, :string, default: '未設定'
    change_column :line_users, :address_city, :string, default: '未設定'
  end

  def down
    change_column :line_users, :zip, :string
    change_column :line_users, :address_country, :string
    change_column :line_users, :address_state, :string
    change_column :line_users, :address_street, :string
    change_column :line_users, :address_city, :string
  end
end
