class AddUniqueIdToCompanies < ActiveRecord::Migration[5.0]
  def change
    add_column :companies, :unique_id, :string
  end
end
