class RenameNameColumnToShippingCompanies < ActiveRecord::Migration[5.0]
  def change
    rename_column :shipping_companies, :name, :shipping_company_name
  end
end
