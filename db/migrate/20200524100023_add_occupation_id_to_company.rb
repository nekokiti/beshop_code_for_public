class AddOccupationIdToCompany < ActiveRecord::Migration[5.0]
  def change
    add_column :companies, :occupation_mst_id, :integer, default: nil
  end
end
