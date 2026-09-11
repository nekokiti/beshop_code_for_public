class AddTelToLineUsers < ActiveRecord::Migration[5.0]
  def change
    add_column :line_users, :tel, :string
  end
end
