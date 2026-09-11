class ChangeOccupationMstIdToCompany < ActiveRecord::Migration[5.0]
  def up
    change_column :companies, :occupation_mst_id, :integer, default: 0
  end

  def down
    change_column :companies, :occupation_mst_id, :integer, default: nil
  end
end
