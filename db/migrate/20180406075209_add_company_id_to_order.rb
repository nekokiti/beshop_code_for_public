class AddCompanyIdToOrder < ActiveRecord::Migration[5.0]
  def change
    add_column :orders, :company_id, :integer
  end
end
