class RemoveTokenToCarts < ActiveRecord::Migration[5.0]
  def up
	  remove_column :carts, :token
  end
  def down
	  add_column :carts, :token, :string
  end
end
