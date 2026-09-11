class RemoveColumnToGottenProducts < ActiveRecord::Migration[5.0]
  def up
	  remove_column :gotten_products, :click_num
  end
  def down
	  add_column :gotten_products, :click_num, :integer
  end
end
