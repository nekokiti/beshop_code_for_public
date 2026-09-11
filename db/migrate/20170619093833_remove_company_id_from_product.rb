class RemoveCompanyIdFromProduct < ActiveRecord::Migration[5.0]
  def up
	  remove_column :products, :company_id
  end
  def down
	  add_column :products, :company_id, :integer
  end
end
