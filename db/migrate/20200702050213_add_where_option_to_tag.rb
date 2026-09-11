class AddWhereOptionToTag < ActiveRecord::Migration[5.0]
  def up
		remove_index :tags, [:tag_name, :company_id]
		add_index :tags, [:tag_name, :company_id], :unique => true, where: 'deleted_at IS NULL'
  end
  def down
		add_index :tags, [:tag_name, :company_id], :unique => true
  end
end
