class AddCompanyIdToProduct < ActiveRecord::Migration[5.0]
  def change
    add_column :products, :company_id, :integer
  end
end
