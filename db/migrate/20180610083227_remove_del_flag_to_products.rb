class RemoveDelFlagToProducts < ActiveRecord::Migration[5.0]
  def up
	  remove_column :products, :del_flg
  end
  def down
	  add_column :products, :del_flg, :boolean
  end
end
