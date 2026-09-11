class AddEnableFlgToPaypalInfo < ActiveRecord::Migration[5.0]
  def change
    add_column :paypal_infos, :enable_flg, :boolean, null: false, default: false
  end
end
