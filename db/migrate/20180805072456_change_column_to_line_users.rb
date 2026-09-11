class ChangeColumnToLineUsers < ActiveRecord::Migration[5.0]
  def up
    change_column_null :line_users, :line_id, true
  end
  def down
    change_column_null :line_users, :line_id, false
  end
end
