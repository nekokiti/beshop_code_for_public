class AddIndexToTag < ActiveRecord::Migration[5.0]
  def change
	  add_index :tags, :tag_name, :unique => true
  end
end
