class AddNoExtraFeeFlgToProduct < ActiveRecord::Migration[5.0]
  def change
    add_column :products, :no_extra_fee, :boolean, default: false
  end
end
