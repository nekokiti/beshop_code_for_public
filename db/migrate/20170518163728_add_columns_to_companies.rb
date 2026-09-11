class AddColumnsToCompanies < ActiveRecord::Migration[5.0]
  def change
    add_column :companies, :company_name, :string
  end
end
