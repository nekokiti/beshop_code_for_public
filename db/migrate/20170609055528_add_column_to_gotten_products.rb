class AddColumnToGottenProducts < ActiveRecord::Migration[5.0]
  def change
	  add_column :gotten_products, :click_flg, :boolean, default: false
	  add_column :gotten_products, :next_flg, :boolean, default: false
  end
end
