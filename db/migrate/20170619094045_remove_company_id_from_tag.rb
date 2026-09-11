class RemoveCompanyIdFromTag < ActiveRecord::Migration[5.0]
  def up
	  remove_column :tags, :company_id
  end
  def down
	  add_column :tags, :company_id, :integer
  end
end
