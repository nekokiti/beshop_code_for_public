class AddEnableFlgToLinePayInfo < ActiveRecord::Migration[5.0]
  def change
    add_column :line_pay_infos, :enable_flg, :boolean, null: false, default: false
  end
end
