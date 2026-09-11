class AddCompanyIdToTag < ActiveRecord::Migration[5.0]
  def change
    add_column :tags, :company_id, :integer
  end
end
