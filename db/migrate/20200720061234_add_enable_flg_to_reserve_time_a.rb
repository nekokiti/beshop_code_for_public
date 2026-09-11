class AddEnableFlgToReserveTimeA < ActiveRecord::Migration[5.0]
  def change
    add_column :reserve_time_as, :enable_flg, :boolean, default: false
  end
end
