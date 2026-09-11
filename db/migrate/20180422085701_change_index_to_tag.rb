class ChangeIndexToTag < ActiveRecord::Migration[5.0]
	def up
		remove_index :tags, :tag_name
		add_index :tags, [:tag_name, :company_id], :unique => true
  end
	def down
		add_index :tags, :tag_name, :unique => true
	end
end
