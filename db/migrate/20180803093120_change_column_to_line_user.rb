class ChangeColumnToLineUser < ActiveRecord::Migration[5.0]
  def change
    add_column :line_users, :provider, :string
    add_column :line_users, :uid, :string
    add_column :line_users, :name, :string
  end
end
