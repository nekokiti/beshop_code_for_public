class AddOtoriokiFlgToProduct < ActiveRecord::Migration[5.0]
  def change
    add_column :products, :otorioki_flg, :boolean, default: false
  end
end
