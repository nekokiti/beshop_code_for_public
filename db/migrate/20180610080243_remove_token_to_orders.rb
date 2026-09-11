class RemoveTokenToOrders < ActiveRecord::Migration[5.0]
  def up
	  remove_column :orders, :token
  end
  def down
	  add_column :orders, :token, :string
  end
end
