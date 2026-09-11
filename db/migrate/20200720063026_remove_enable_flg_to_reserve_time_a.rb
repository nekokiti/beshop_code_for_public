class RemoveEnableFlgToReserveTimeA < ActiveRecord::Migration[5.0]
  def up
    remove_column :reserve_time_as, :enable_flg
  end
  def down
    add_column :reserve_time_as, :enable_flg, :boolean, default: false
  end
end
