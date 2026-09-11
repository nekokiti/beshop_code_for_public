class ChangeNotNullToLineUser < ActiveRecord::Migration[5.0]
  def up
    remove_index :line_users, :email
    change_column_null :line_users, :email, true
  end
  def down
    add_index :line_users, :email, unique: true
    change_column_null :line_users, :email, false
  end
end
