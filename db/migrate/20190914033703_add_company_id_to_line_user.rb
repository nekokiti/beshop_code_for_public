class AddCompanyIdToLineUser < ActiveRecord::Migration[5.0]
  def change
    add_column :line_users, :company_id, :integer
  end
end
