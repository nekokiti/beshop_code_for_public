class RemoveEnableFlgToReserveTimeB < ActiveRecord::Migration[5.0]
  def up
    remove_column :reserve_time_bs, :enable_flg
  end
  def down
    add_column :reserve_time_bs, :enable_flg, :boolean, default: false
  end
end
